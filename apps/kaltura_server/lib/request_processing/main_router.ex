defmodule KalturaServer.RequestProcessing.MainRouter do
  @moduledoc """
  Routes btv and live requests to appropriate modules.
  """

  use Plug.Router

  alias KalturaServer.RequestProcessing.{DataReader, Responser}

  import Plug.Conn, only: [send_resp: 3]

  plug(Plug.Logger, log: :debug)
  plug(DataReader)
  plug(:match)
  plug(:dispatch)

  get "/btv/live/*_rest" do
    {response_conn, status, body} = Responser.make_response(conn)
    send_resp(response_conn, status, body)
  end

  match _ do
    send_resp(conn, 400, "Request invalid")
  end
end
