defmodule KalturaAdmin.Observers.DomainModelObserver do
  @moduledoc false
  use Observable, :observer

  alias KalturaAdmin.Services.DomainModelCache

  def handle_notify({_action, _record}) do
    DomainModelCache.get_all_records()

    :ok
  end
end
