defmodule KalturaAdmin.Observers.DomainModelNotifier do
  @moduledoc false

  defmacro __using__(opts) do
    observer_modules = Keyword.get(opts, :observers, [])

    quote do
      use Observable, :notifier

      observations do
        action(:insert, unquote(observer_modules))
        action(:update, unquote(observer_modules))
        action(:delete, unquote(observer_modules))
      end
    end
  end
end
