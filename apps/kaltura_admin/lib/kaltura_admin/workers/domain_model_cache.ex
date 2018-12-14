defmodule KalturaAdmin.Workers.DomainModelCache do
  @moduledoc """
  Contains logic for caching domain model.
  """

  alias KalturaAdmin.Repo
  alias KalturaAdmin.Protocols.NotifyServerAttrs

  @caching_models [
    {KalturaAdmin.Area.Region, [:subnets, :server_groups]},
    {KalturaAdmin.Area.Subnet, []},
    {KalturaAdmin.Content.Program, []},
    {KalturaAdmin.Content.ProgramRecord, []},
    {KalturaAdmin.Content.TvStream, []},
    {KalturaAdmin.Servers.Server, []},
    {KalturaAdmin.Servers.ServerGroup, [:servers]}
  ]

  @handler Application.get_env(:kaltura_server, :domain_model_handler)

  defp handler, do: @handler

  def perform do
    @caching_models
    |> Enum.each(fn {model, preloads} ->
      model
      |> Repo.all()
      |> Repo.preload(preloads)
      |> Enum.each(&cache_record/1)
    end)
  end

  defp cache_record(record) do
    handler().handle(:refresh, %{
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
