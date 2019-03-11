defmodule KalturaAdmin.PublicApi do
  @moduledoc """
  Содержит функции для запроса данных для кеширования.
  """

  alias KalturaAdmin.Services.DomainModelCache

  def cache_domain_model_at_server do
    DomainModelCache.get_all_records()

    :ok
  end
end
