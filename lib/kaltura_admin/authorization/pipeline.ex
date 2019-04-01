defmodule CtiKaltura.Authorization.Pipeline do
  @moduledoc false

  use Guardian.Plug.Pipeline,
    otp_app: :auth_ex,
    error_handler: CtiKaltura.Authorization.ErrorHandler,
    module: CtiKaltura.Authorization.Guardian

  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})

  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})

  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
