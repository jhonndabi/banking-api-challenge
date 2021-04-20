defmodule BankingApiChallenge.Accounts do
  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Users.Schemas.User
  alias BankingApiChallenge.Repo

  @agency_random_range 1_000..9_999
  @account_number_random_range 1_000_000..9_999_999

  def generate_new_account(%User{} = user) do
    account =
      Account.changeset(%{
        agency: Enum.random(@agency_random_range),
        account_number: Enum.random(@account_number_random_range),
        user_id: user.id
      })

    Repo.insert(account)
  end
end
