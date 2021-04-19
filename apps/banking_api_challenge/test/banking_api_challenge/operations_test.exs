defmodule BankingApiChallenge.OperationsTest do
  use BankingApiChallenge.DataCase, async: true

  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Operations
  alias BankingApiChallenge.Users.Schemas.User
  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Users.Schemas.User

  describe "make_withdraw/1" do
    setup do
      user =
        %User{name: "random name", email: "#{Ecto.UUID.generate()}@email.com"}
        |> Repo.insert!()

      {:ok, account} = Accounts.generate_new_account(user)

      Operations.make_deposit(account.id, 1_000_00)

      {:ok, account: account}
    end

    test "fail if withdraw amount is greater than account balance", state do
      account = state[:account]

      {:error, result} = Operations.make_withdraw(account.id, 1_000_01)

      expected_error = [
        balance: {"must be greater than or equal to %{number}",
        [validation: :number, kind: :greater_than_or_equal_to, number: 0]}
      ]

      assert expected_error == result.errors

      query = from(a in Account, where: a.id == ^account.id)

      account = Repo.one(query)

      assert account.balance == 1_000_00
    end

    test "successfully make withdraw with valid input", state do
      account = state[:account]

      Operations.make_withdraw(account.id, 250_00)

      query = from(a in Account, where: a.id == ^account.id)

      account = Repo.one(query)

      assert account.balance == 750_00
    end
  end
end
