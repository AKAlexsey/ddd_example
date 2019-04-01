defmodule CtiKaltura.Repo do
  use Ecto.Repo,
    otp_app: :cti_kaltura,
    adapter: Ecto.Adapters.Postgres

  use Observable.Repo
end
