defmodule CtiKaltura.PublicApi do
  @moduledoc """
  Содержит функции для запроса данных для кеширования.
  """

  alias CtiKaltura.Services.DomainModelCache

  def cache_domain_model_at_server do
    DomainModelCache.get_all_records()

    :ok
  end

  def cache_model_record(model, id) do
    DomainModelCache.get_one_record(model, id)

    :ok
  end
end
