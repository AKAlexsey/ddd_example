defmodule CtiKaltura.RequestProcessing.RequestHelper do
  @moduledoc """
  Contains some share logic for requests.
  """
  def normalize_encryption("pr"), do: "PLAYREADY"
  def normalize_encryption("wv"), do: "WIDEVINE"
  def normalize_encryption(""), do: "NONE"
  def normalize_encryption(enc), do: enc

  def obtain_entity_by_encryption(recs, enc) when enc in ["NONE", "CENC"] do
    Enum.find(recs, fn rec -> rec.encryption == enc end)
  end

  def obtain_entity_by_encryption(recs, enc) do
    case Enum.find(recs, fn rec -> rec.encryption == enc end) do
      nil -> obtain_entity_by_encryption(recs, "CENC")
      rec -> rec
    end
  end
end
