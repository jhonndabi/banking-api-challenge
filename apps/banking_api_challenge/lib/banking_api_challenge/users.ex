defmodule BankingApiChallenge.Users do
  alias BankingApiChallenge.Users.Schemas.User
  alias BankingApiChallenge.Repo

  def create_user(%User{} = user) do
    user
    |> Repo.insert()
  end
end
