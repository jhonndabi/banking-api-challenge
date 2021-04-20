defmodule BankingApiChallenge.Accounts do
  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Users.Schemas.User
  alias BankingApiChallenge.Repo

  @agency_random_range 1_000..9_999
  @account_number_random_range 1_000_000..9_999_999

  def generate_new_account(%User{} = user) do
    account =
      Account.changeset(%{
        agency: random_range_to_string(@agency_random_range),
        account_number: random_range_to_string(@account_number_random_range),
        user_id: user.id
      })

    Repo.insert(account)
  end

  defp random_range_to_string(random_range) do
    random_range
    |> Enum.random()
    |> Integer.to_string()
  end
end
