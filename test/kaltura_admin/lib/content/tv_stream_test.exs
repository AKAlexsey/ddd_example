defmodule CtiKaltura.TvStreamTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Content.TvStream

  describe "#changeset" do
    setup do
      {:ok, tv_stream} = Factory.insert(:tv_stream)

      {:ok, tv_stream: tv_stream}
    end

    test "Validate :stream_path presence", %{tv_stream: tv_stream} do
      refute is_nil(tv_stream.stream_path)
      changeset = TvStream.changeset(tv_stream, %{stream_path: nil})

      assert %{valid?: false, errors: [stream_path: _]} = changeset
    end

    test "Validate :status presence", %{tv_stream: tv_stream} do
      refute is_nil(tv_stream.status)
      changeset = TvStream.changeset(tv_stream, %{status: nil})

      assert %{valid?: false, errors: [status: _]} = changeset
    end

    test "Validate :protocol presence", %{tv_stream: tv_stream} do
      refute is_nil(tv_stream.protocol)
      changeset = TvStream.changeset(tv_stream, %{protocol: nil})

      assert %{valid?: false, errors: [protocol: _]} = changeset
    end

    test "Validate :encryption presence", %{tv_stream: tv_stream} do
      refute is_nil(tv_stream.encryption)
      changeset = TvStream.changeset(tv_stream, %{encryption: nil})

      assert %{valid?: false, errors: [encryption: _]} = changeset
    end

    test "Validate :linear_channel exist", %{tv_stream: tv_stream} do
      changeset = TvStream.changeset(tv_stream, %{linear_channel_id: 777})
      assert {:error, %{valid?: false, errors: [linear_channel: _]}} = Repo.update(changeset)
    end

    test "Validate :stream_path is uniq", %{tv_stream: tv_stream} do
      {:ok, other_server} = Factory.insert(:tv_stream)

      refute tv_stream.stream_path == other_server.stream_path
      changeset = TvStream.changeset(tv_stream, %{stream_path: other_server.stream_path})
      assert {:error, %{valid?: false, errors: [stream_path: _]}} = Repo.update(changeset)
    end

    test "Validate :stream_path format #1", %{tv_stream: tv_stream} do
      changeset = TvStream.changeset(tv_stream, %{stream_path: "path/stream"})
      assert {:error, %{valid?: false, errors: [stream_path: _]}} = Repo.update(changeset)
    end

    test "Validate :stream_path format #2", %{tv_stream: tv_stream} do
      valid_path = "/path/stream"
      changeset = TvStream.changeset(tv_stream, %{stream_path: valid_path})
      assert {:ok, %TvStream{stream_path: ^valid_path}} = Repo.update(changeset)
    end
  end
end
