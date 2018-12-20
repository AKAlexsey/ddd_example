defmodule KalturaAdmin.PublicApi do
  @moduledoc """
  Содержит функции для запроса данных для кеширования.
  """

  alias KalturaAdmin.Services.DomainModelCache

  def cache_domain_model_at_server do
    Task.async(fn ->
      DomainModelCache.get_all_records()
    end)

    :ok
  end

  def cache_model_record(model, id) do
    Task.async(fn ->
      DomainModelCache.get_one_record(model, id)
    end)

    :ok
  end
end
