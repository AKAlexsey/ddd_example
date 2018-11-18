defmodule KalturaAdmin.Authorization.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :auth_ex,
    error_handler: KalturaAdmin.Authorization.ErrorHandler,
    module: KalturaAdmin.Authorization.Guardian

  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})

  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})

  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
