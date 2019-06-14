defmodule CtiKaltura.ProgramScheduling.SoapRequests do
  @moduledoc """
  Содержит функции для отправки запросов на DVR сервер.
  """

  alias CtiKaltura.Content.ProgramRecord
  alias CtiKaltura.ProgramScheduling.{DvrSoapRequestsWorker, SoapServersService, Time}
  alias Soap.Response.Parser

  @doc """
  *В данный момент не используется. Было решено не скачивать каждый раз WSDL файл, а сохранить его в корне проекта*
  Осуществляет запрос на получение WSDL.
  В случае успеха парсит и возаращет {:ok, map_with_allowed_functions}.
  В случае провала возаращет ошибку
  """
  @spec get_wsdl_file(binary, binary, binary) :: {:ok, map()} | {:error, atom()}
  def get_wsdl_file(path, user, password) do
    with %HTTPoison.Response{status_code: 200, body: body} <- wsdl_request(path, user, password),
         {:ok, parsed_wsdl} <- Soap.Wsdl.parse(body, path) do
      {:ok, parsed_wsdl}
    else
      %HTTPoison.Response{status_code: 500} ->
        {:error, :request_fail}

      %HTTPoison.Response{status_code: 401} ->
        {:error, :unauthorized}

      %HTTPoison.Response{status_code: 404} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}

      _ ->
        {:error, :unknown_error}
    end
  end

  defp wsdl_request(path, user, password) do
    HTTPoison.get!(
      path,
      [Authorization: "Basic #{Base.encode64("#{user}:#{password}")}"],
      follow_recdirect: false
    )
  end

  @doc """
  Осуществляет подготовку параметров и отправку SOAP запроса scheduleRecording на DVR сервер.
  Или возвращает ошибку.
  """
  @spec schedule_recording(tuple()) :: {:ok, any} | {:error, any}
  def schedule_recording({program, linear_channel, tv_stream}) do
    safe_request("scheduleRecording", {program, linear_channel, tv_stream}, false)
  end

  @doc """
  Осуществляет подготовку параметров и отправку SOAP запроса getRecording на DVR сервер.
  Или возвращает ошибку.
  """
  @spec get_recording(ProgramRecord.t()) :: {:ok, any} | {:error, any}
  def get_recording(params) do
    safe_request("getRecording", params, false)
  end

  @doc """
  Осуществляет подготовку параметров и отправку SOAP запроса removeRecording на DVR сервер.
  Или возвращает ошибку.
  """
  @spec remove_recording(ProgramRecord.t()) :: {:ok, any} | {:error, any}
  def remove_recording(params) do
    safe_request("removeRecording", params, true)
  end

  defp safe_request(operation, params, async) do
    with {:ok, soap_params} <- get_params(operation, params),
         dvr_server_domain when is_binary(dvr_server_domain) <-
           SoapServersService.dvr_server_domain(params),
         result <- perform_request(operation, soap_params, dvr_server_domain, async) do
      result
    else
      {:error, reason} ->
        {:error, reason}

      nil ->
        {:error, :no_dvr_server}
    end
  end

  @spec get_params(binary, any()) :: {:ok, map()} | {:error, :invalid_params}
  def get_params("scheduleRecording", {
        %{
          epg_id: epg_id,
          start_datetime: start_datetime,
          end_datetime: end_datetime
        },
        %{
          code_name: code_name
        } = linear_channel,
        %{
          stream_path: stream_path,
          protocol: protocol,
          encryption: encryption
        }
      }) do
    case SoapServersService.edge_server_domain(linear_channel) do
      nil ->
        {:error, :no_edge_server}

      edge_server_doman ->
        request_params = %{
          plannedStartTime: Time.soap_datetime(start_datetime),
          plannedEndTime: Time.soap_datetime(end_datetime),
          assetToCapture: "#{edge_server_doman}#{stream_path}",
          placement: "#{code_name}/#{protocol}/#{encryption}/#{epg_id}",
          params:
            "format=#{String.downcase(protocol)};encryption=#{String.downcase(encryption)};channel=#{
              code_name
            }#{storage_id_parameter(linear_channel)}"
        }

        {:ok, %{arg0: request_params}}
    end
  end

  def get_params("getRecording", %{path: path}) do
    {:ok, %{arg0: path}}
  end

  def get_params("removeRecording", %{path: path}) do
    {:ok, %{arg0: path}}
  end

  def get_params(_, _) do
    {:error, :invalid_params}
  end

  defp storage_id_parameter(%{storage_id: storage_id}) when is_integer(storage_id) do
    ";storageID=#{storage_id}"
  end

  defp storage_id_parameter(_), do: ""

  defp perform_request(operation, params, dvr_server_domain, true) do
    DvrSoapRequestsWorker.async_request(operation, params, dvr_server_domain)
  end

  defp perform_request(operation, params, dvr_server_domain, false) do
    DvrSoapRequestsWorker.sync_request(operation, params, dvr_server_domain)
  end

  @doc "Осуществляет SOAP запрос"
  def soap_request(wsdl, operation, soap_headers_and_params, request_headers \\ [], opts \\ []) do
    Soap.Request.call(wsdl, operation, soap_headers_and_params, request_headers, opts)
  end

  @doc """
  Возвращает заголовок для Basic авторизации, с закодированными Base64 авторизационными данными
  пользователем и паролем.
  """
  @spec authorization_header(binary, binary) :: binary
  def authorization_header(user, password) do
    "Basic #{Base.encode64("#{user}:#{password}")}"
  end

  @doc """
  Парсит ответ и возвращает {:ok, map_answer} | {:error, map_error_details}
  """
  @spec parse_response(binary) :: {:ok, map()} | {:error, map()}
  def parse_response(response) do
    response
    |> Map.get(:body)
    |> Parser.parse(:all)
    |> case do
      %{:"soap:Fault" => fault_response} ->
        {:error, fault_response}

      parsed_response ->
        success_response =
          parsed_response
          |> Map.values()
          |> hd()
          |> (fn
                %{return: return} -> return
                void_response -> void_response
              end).()

        {:ok, success_response}
    end
  end
end
