defmodule KalturaAdmin.Services.DomainModelCache do
  @moduledoc """
  Содержит логику подгрузки моделей данных из базы.
  """

  alias KalturaAdmin.Protocols.NotifyServerAttrs
  alias KalturaAdmin.Repo

  import Ecto.Query, only: [from: 2]

  @caching_models [
    {KalturaAdmin.Area.Region, [:subnets, :server_groups]},
    {KalturaAdmin.Area.Subnet, [region: [server_groups: :servers]]},
    {KalturaAdmin.Content.Program, [:program_records, :linear_channel]},
    {KalturaAdmin.Content.ProgramRecord, [:program, :server]},
    {KalturaAdmin.Content.LinearChannel, [:server_group, :programs, :tv_streams]},
    {KalturaAdmin.Content.TvStream, [:linear_channel]},
    {KalturaAdmin.Servers.Server, [:program_records, [server_groups: [regions: :subnets]]]},
    {KalturaAdmin.Servers.ServerGroup, [:servers, :linear_channels, [regions: :subnets]]}
  ]

  @handler Application.get_env(:kaltura_server, :domain_model_handler)

  defp handler, do: @handler

  def get_all_records do
    Task.async(fn ->
      @caching_models
      |> Enum.each(fn {model, preloads} ->
        model
        |> Repo.all()
        |> Repo.preload(preloads)
        |> Enum.each(&cache_record(&1, :refresh_by_request))
      end)
    end)
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
