defmodule Discogrify.Repo do
  use Ecto.Repo,
    otp_app: :discogrify,
    adapter: Ecto.Adapters.Postgres
end
