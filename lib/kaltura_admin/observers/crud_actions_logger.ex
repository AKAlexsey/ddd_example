defmodule CtiKaltura.Observers.CrudActionsLogger do
  @moduledoc false

  use CtiKaltura.KalturaLogger, metadata: [domain: :database]
  use Observable, :observer

  alias CtiKaltura.User

  @filter_string "[FILTERED]"

  def handle_notify({:insert, record}) do
    log_database_crud_operation(record, "Create")

    :ok
  end

  def handle_notify({:update, [_old_record, new_record]}) do
    log_database_crud_operation(new_record, "Update")

    :ok
  end

  def handle_notify({:delete, record}) do
    log_database_crud_operation(record, "Delete")

    :ok
  end

  defp log_database_crud_operation(record, operation) do
    log_info("#{operation} #{model_name(record)} #{inspect_record(record)}")
  end

  defp inspect_record(%User{} = user) do
    user
    |> Map.update!(:password, fn _val -> @filter_string end)
    |> Map.update!(:password_hash, fn _val -> @filter_string end)
    |> inspect()
  end

  defp inspect_record(record), do: inspect(record)

  defp model_name(record) do
    record.__struct__
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
  end
end
