defmodule CtiKaltura.RequestProcessing.RequestHelperTest do
  # use ExUnit.Case
  use CtiKaltura.ConnCase

  import CtiKaltura.RequestProcessing.RequestHelper

  describe "obtain_entity_by_encryption() : " do
    test "all types is present" do
      recs = [
        %{encryption: "NONE"},
        %{encryption: "PLAYREADY"},
        %{encryption: "WIDEVINE"},
        %{encryption: "CENC"}
      ]

      assert obtain_entity_by_encryption(recs, "NONE") == %{encryption: "NONE"}
      assert obtain_entity_by_encryption(recs, "PLAYREADY") == %{encryption: "PLAYREADY"}
      assert obtain_entity_by_encryption(recs, "WIDEVINE") == %{encryption: "WIDEVINE"}
      assert obtain_entity_by_encryption(recs, "CENC") == %{encryption: "CENC"}
    end

    test "NONE and CENC is present" do
      recs = [%{encryption: "NONE"}, %{encryption: "CENC"}]

      assert obtain_entity_by_encryption(recs, "NONE") == %{encryption: "NONE"}
      assert obtain_entity_by_encryption(recs, "PLAYREADY") == %{encryption: "CENC"}
      assert obtain_entity_by_encryption(recs, "WIDEVINE") == %{encryption: "CENC"}
      assert obtain_entity_by_encryption(recs, "CENC") == %{encryption: "CENC"}
    end

    test "NONE and PLAYREADY is present" do
      recs = [%{encryption: "NONE"}, %{encryption: "PLAYREADY"}]

      assert obtain_entity_by_encryption(recs, "NONE") == %{encryption: "NONE"}
      assert obtain_entity_by_encryption(recs, "PLAYREADY") == %{encryption: "PLAYREADY"}
      assert obtain_entity_by_encryption(recs, "WIDEVINE") == nil
      assert obtain_entity_by_encryption(recs, "CENC") == nil
    end

    test "NONE and WIDEVINE is present" do
      recs = [%{encryption: "NONE"}, %{encryption: "WIDEVINE"}]

      assert obtain_entity_by_encryption(recs, "NONE") == %{encryption: "NONE"}
      assert obtain_entity_by_encryption(recs, "PLAYREADY") == nil
      assert obtain_entity_by_encryption(recs, "WIDEVINE") == %{encryption: "WIDEVINE"}
      assert obtain_entity_by_encryption(recs, "CENC") == nil
    end

    test "CENC is present" do
      recs = [%{encryption: "CENC"}]

      assert obtain_entity_by_encryption(recs, "NONE") == nil
      assert obtain_entity_by_encryption(recs, "PLAYREADY") == %{encryption: "CENC"}
      assert obtain_entity_by_encryption(recs, "WIDEVINE") == %{encryption: "CENC"}
      assert obtain_entity_by_encryption(recs, "CENC") == %{encryption: "CENC"}
    end
  end

  describe "normalize_encryption() : " do
    test "all types" do
      assert normalize_encryption("pr") == "PLAYREADY"
      assert normalize_encryption("wv") == "WIDEVINE"
      assert normalize_encryption("") == "NONE"
      assert normalize_encryption("unknown") == "unknown"
    end
  end
end
