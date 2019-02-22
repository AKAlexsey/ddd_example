defmodule KalturaAdmin.Services.DomainModelCache do
  @moduledoc """
  Содержит логику подгрузки моделей данных из базы.
  """

  alias KalturaAdmin.Protocols.NotifyServerAttrs
  alias KalturaAdmin.Repo

  import Ecto.Query, only: [from: 2]

  @caching_models [
    {KalturaAdmin.Area.Region, [:subnets, :server_groups]},
    {KalturaAdmin.Area.Subnet, [:region]},
    {KalturaAdmin.Content.Program, [:program_records, :linear_channel]},
    {KalturaAdmin.Content.ProgramRecord, [:program, :server]},
    {KalturaAdmin.Content.LinearChannel, [:server_group, :programs, :tv_streams]},
    {KalturaAdmin.Content.TvStream, [:linear_channel]},
    {KalturaAdmin.Servers.Server, [:server_groups, :program_records]},
    {KalturaAdmin.Servers.ServerGroup, [:servers, :linear_channels, :regions]}
  ]

  @handler Application.get_env(:kaltura_server, :domain_model_handler)

  defp handler, do: @handler

  def get_all_records do
    @caching_models
    |> Enum.each(fn {model, preloads} ->
      model
      |> Repo.all()
      |> Repo.preload(preloads)
      |> Enum.each(&cache_record(&1, :refresh_by_request))
    end)
  end

  def get_one_record(model_name, id) do
    with {:ok, module_name, preloads} <- find_model_module(@caching_models, model_name),
         {:ok, record} <- get_module_record(module_name, id, preloads) do
      cache_record(record, :refresh_by_request)
    else
      {:error, :no_module} ->
        raise "DomainModelCache unknown model name #{inspect(model_name)}"

      {:error, :not_found} ->
        raise "No record for #{model_name} with id #{id}"
    end
  end

  defp find_model_module(caching_models, model_name) do
    caching_models
    |> Enum.find(fn {module_name, _preloads} ->
      module_name
      |> to_string()
      |> String.match?(~r/#{model_name}$/)
    end)
    |> (fn
          nil -> {:error, :no_module}
          {module_name, preloads} -> {:ok, module_name, preloads}
        end).()
  end

  defp get_module_record(module_name, id, preloads) do
    from(model in module_name, where: model.id == ^id, preload: ^preloads)
    |> Repo.one()
    |> (fn
          nil -> {:error, :not_found}
          record -> {:ok, record}
        end).()
  end

  defp cache_record(record, event) do
    handler().handle(event, %{
      model_name: model_name(record),
      attrs: NotifyServerAttrs.get(record)
    })
  end

  defp model_name(record) do
    record.__struct__
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
  end
end
