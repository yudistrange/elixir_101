defmodule Elixir101.Repo do
  use Ecto.Repo,
    otp_app: :elixir_101,
    adapter: Ecto.Adapters.Postgres
end
