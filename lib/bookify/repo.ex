defmodule Bookify.Repo do
  use Ecto.Repo,
    otp_app: :bookify,
    adapter: Ecto.Adapters.Postgres
end
