defmodule Understanding.Repo do
  use Ecto.Repo,
    otp_app: :understanding,
    adapter: Ecto.Adapters.Postgres
end
