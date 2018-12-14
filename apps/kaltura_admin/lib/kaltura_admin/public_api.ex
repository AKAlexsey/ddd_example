defmodule KalturaAdmin.PublicApi do
  @moduledoc """
  Public interface for manipulations with domain model
  """

  alias KalturaAdmin.Workers.DomainModelCache

  def cache_domain_model_at_server do
    DomainModelCache.perform()
  end
end
