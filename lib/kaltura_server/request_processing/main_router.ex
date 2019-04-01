defmodule CtiKaltura.RequestProcessing.MainRouter do
  @moduledoc """
  Routes btv and live requests to appropriate modules.
  """

  use Plug.Router

  alias CtiKaltura.RequestProcessing.{
    CatchupResponser,
    DataReader,
    LiveResponser,
    VodResponser
  }

  import Plug.Conn, only: [send_resp: 3]

  plug(Plug.Logger, log: :debug)
  plug(DataReader)
  plug(:match)
  plug(:dispatch)

  get "/btv/live/*_rest" do
    {response_conn, status, body} = LiveResponser.make_response(conn)
    send_resp(response_conn, status, body)
  end

  get "/btv/catchup/*_rest" do
    {response_conn, status, body} = CatchupResponser.make_response(conn)
    send_resp(response_conn, status, body)
  end

  get "/vod/*_vod_path" do
    {response_conn, status, body} = VodResponser.make_response(conn)
    send_resp(response_conn, status, body)
  end

  match _ do
    send_resp(conn, 400, "Request invalid")
  end
end
