defmodule BankingApiChallengeWeb.Router do
  use BankingApiChallengeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", BankingApiChallengeWeb do
    pipe_through :api

    post "/signups", SignUpController, :sign_up
    post "/withdrawals", WithdrawalController, :withdrawal
    post "/transfers", TransferController, :transfer
  end
end
