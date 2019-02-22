defmodule KalturaAdmin.TvStreamView do
  use KalturaAdminWeb, :view

  alias KalturaAdmin.Content.TvStream

  defdelegate statuses, to: TvStream
  defdelegate protocols, to: TvStream
  defdelegate encryption, to: TvStream
end
