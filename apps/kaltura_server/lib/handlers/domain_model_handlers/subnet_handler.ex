defmodule KalturaServer.DomainModelHandlers.SubnetHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.Subnet

  @joined_attributes_and_models [
    region_id: "Region"
  ]

  @kaltura_server_public_api Application.get_env(:kaltura_admin, :public_api)[:module]

  def handle(action, attrs) when action in [:insert, :update, :refresh] do
    Amnesia.transaction do
      refresh_linked_tables_if_necessary(attrs)
      write_to_table(attrs)
    end

    :ok
  end

  def handle(:refresh_by_request, attrs) do
    Amnesia.transaction do
      write_to_table(attrs)
    end
  end

  def handle(:delete, %{id: id}) do
    Amnesia.transaction do
      Subnet.delete(id)
    end
  end

  defp write_to_table(attrs) do
    %Subnet{}
    |> struct(attrs)
    |> Subnet.write()
  end

  defp refresh_linked_tables_if_necessary(%{id: id} = attrs) do
    case Subnet.read(id) do
      nil ->
        :ok

      record ->
        @joined_attributes_and_models
        |> Enum.each(fn {attribute, model_name} ->
          current_value = Map.get(record, attribute)
          new_value = Map.get(attrs, attribute)

          if current_value == new_value do
            :ok
          else
            @kaltura_server_public_api.cache_model_record(model_name, current_value)
            @kaltura_server_public_api.cache_model_record(model_name, new_value)
          end
        end)
    end
  end
end
