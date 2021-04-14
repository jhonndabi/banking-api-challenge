defmodule BankingApiChallenge.Repo do
  use Ecto.Repo,
    otp_app: :banking_api_challenge,
    adapter: Ecto.Adapters.Postgres
end
