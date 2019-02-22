defmodule KalturaAdmin.ProgramView do
  use KalturaAdminWeb, :view

  alias KalturaAdmin.Content

  def linear_channels do
    Content.list_linear_channels()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end

  def linear_channel_name(%{linear_channel: linear_channel}) when not is_nil(linear_channel) do
    linear_channel.name
  end

  def linear_channel_name(_), do: ""
end
