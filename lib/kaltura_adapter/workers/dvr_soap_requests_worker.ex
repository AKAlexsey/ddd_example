defmodule CtiKaltura.ProgramScheduling.DvrSoapRequestsWorker do
  @moduledoc """
  Осуществлят отправку запросов DVR на запись программ.
  На старте осуществлят загрузку WSDL файла.
  """

  use GenServer
  use CtiKaltura.KalturaLogger, metadata: [domain: :program_scheduling]

  alias CtiKaltura.ProgramScheduling.SoapRequests

  @max_get_wsdl_file_attempt 5
  @sync_request_awaiting_time 10_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: via_tuple(__MODULE__))
  end

  def async_request(operation, params, dvr_server_domain) do
    GenServer.cast(
      via_tuple(__MODULE__),
      {:request, operation, params, dvr_server_domain}
    )
  end

  def sync_request(operation, params, dvr_server_domain) do
    GenServer.call(
      via_tuple(__MODULE__),
      {:request, operation, params, dvr_server_domain},
      @sync_request_awaiting_time
    )
  end

  @spec get_wsdl_file :: :ok | {:error, :no_such_process}
  def get_wsdl_file do
    __MODULE__
    |> via_tuple()
    |> GenServer.whereis()
    |> case do
      pid when is_pid(pid) ->
        Process.send_after(pid, :get_wsdl_file, 0)
        :ok

      _ ->
        {:error, :no_such_process}
    end
  end

  def init(_) do
    log_info("Starting")
    schedule_get_wsdl_file()

    {:ok,
     %{
       ready: false,
       get_wsdl_file_attempt: 1,
       parsed_wsdl: nil,
       soap_user: soap_user(),
       soap_password: soap_password()
     }}
  end

  defp schedule_get_wsdl_file(interval \\ 0) do
    if enabled?() do
      Process.send_after(self(), :get_wsdl_file, interval)
    end
  end

  defp via_tuple(name) do
    {:global, name}
  end

  def handle_info(:get_wsdl_file, %{get_wsdl_file_attempt: attempt} = state) do
    if attempt > @max_get_wsdl_file_attempt do
      log_error("Getting WSDL file failed. Achieved maximum attempt. Stop parsing.")

      {:noreply, Map.merge(state, %{ready: false, get_wsdl_file_attempt: 1})}
    else
      case safe_load_file() do
        {:ok, parsed_wsdl} ->
          log_info("WSDL schema has been loaded")

          {:noreply,
           Map.merge(state, %{ready: true, get_wsdl_file_attempt: 1, parsed_wsdl: parsed_wsdl})}

        {:error, reason} ->
          log_error("Getting WSDL file failed. Attempt: #{attempt}. Reason #{inspect(reason)}.")

          schedule_get_wsdl_file(run_interval())
          {:noreply, Map.merge(state, %{ready: false, get_wsdl_file_attempt: attempt + 1})}
      end
    end
  end

  defp safe_load_file do
    with {:ok, _file} <- File.read(wsdl_file_path()),
         {:ok, parsed_wsdl} <- Soap.init_model(wsdl_file_path(), :file) do
      {:ok, parsed_wsdl}
    end
  catch
    _kind, reason ->
      {:error, reason}
  end

  def handle_cast({:request, operation, params, dvr_server_domain}, state) do
    perform_request(operation, params, dvr_server_domain, state)

    {:noreply, state}
  end

  def handle_cast(request, state) do
    log_error("Unknown cast\nRequest: #{inspect(request)}\nState: #{inspect(state)}")
    {:noreply, state}
  end

  def handle_call(
        {:request, operation, params, dvr_server_domain},
        _from,
        state
      ) do
    case perform_request(operation, params, dvr_server_domain, state) do
      {:ok, response} ->
        parsed_response = SoapRequests.parse_response(response)
        {:reply, parsed_response, state}

      {:error, reason} ->
        {:reply, reason, state}
    end
  end

  def handle_call(request, from, state) do
    log_error(
      "Unknown call\nRequest: #{inspect(request)}\nFrom: #{inspect(from)}\nState: #{
        inspect(state)
      }"
    )

    {:reply, :error, state}
  end

  defp perform_request(operation, params, dvr_server_domain, %{
         parsed_wsdl: wsdl,
         soap_user: user,
         soap_password: password
       }) do
    SoapRequests.soap_request(
      put_dvr_server_domain(wsdl, dvr_server_domain),
      operation,
      {%{}, params},
      [Authorization: SoapRequests.authorization_header(user, password)],
      []
    )
  end

  defp put_dvr_server_domain(wsdl, dvr_server_domain) do
    Map.update!(wsdl, :endpoint, fn _val -> dvr_server_domain end)
  end

  # Configuration functions
  defp config, do: Application.get_env(:cti_kaltura, :dvr_soap_requests)

  defp enabled?, do: config()[:enabled]

  def run_interval, do: config()[:run_interval]

  def wsdl_file_path, do: config()[:wsdl_file_path]

  def soap_user, do: config()[:soap_user]

  def soap_password, do: config()[:soap_password]
end
