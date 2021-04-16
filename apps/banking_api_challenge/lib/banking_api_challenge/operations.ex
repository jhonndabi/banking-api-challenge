defmodule BankingApiChallenge.Operations do

  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Operations.Schemas.Operation
  alias BankingApiChallenge.Repo

  def make_deposit(%Account{} = account, amount) when is_integer(amount) and amount > 0 do
    operation = Operation.changeset(%{
      type: "deposit",
      account_in: account,
      amount: amount
    })

    Repo.insert(operation)
  end
end
