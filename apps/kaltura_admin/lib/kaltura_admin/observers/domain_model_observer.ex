defmodule KalturaAdmin.Observers.DomainModelObserver do
  @moduledoc false
  use Observable, :observer

  alias KalturaAdmin.Protocols.NotifyServerAttrs

  @handler Application.get_env(:kaltura_server, :domain_model_handler)

  defp handler, do: @handler

  def handle_notify({:insert, record}) do
    handler().handle(:insert, %{
      model_name: model_name(record),
      attrs: NotifyServerAttrs.get(record)
    })

    :ok
  end

  def handle_notify({:update, [_old_record, new_record]}) do
    handler().handle(:update, %{
      model_name: model_name(new_record),
      attrs: NotifyServerAttrs.get(new_record)
    })

    :ok
  end

  def handle_notify({:delete, record}) do
    handler().handle(:delete, %{
      model_name: model_name(record),
      attrs: NotifyServerAttrs.get(record)
    })

    :ok
  end

  defp model_name(record) do
    record.__struct__
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
  end
end
