defmodule KalturaServer.RequestProcessing.MainRouter do
  use Plug.Router

  alias KalturaServer.RequestProcessing.DataReader

  import Plug.Conn, only: [send_resp: 3]

  plug(Plug.Logger, log: :debug)
  plug(DataReader)
  plug(:match)
  plug(:dispatch)

  #  get "/" do
  #    {response_conn, status, body} = Responser.make_response(conn)
  #    send_resp(response_conn, status, body)
  #  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
