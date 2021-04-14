defmodule BankingApiChallengeWeb.Router do
  use BankingApiChallengeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankingApiChallengeWeb do
    pipe_through :api
  end
end
