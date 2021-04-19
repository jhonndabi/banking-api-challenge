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

      assert "must be greater than or equal to 0" in errors_on(result).balance

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

  describe "make_transfer/1" do
    setup do
      user1 =
        %User{name: "random name 1", email: "#{Ecto.UUID.generate()}@email.com"}
        |> Repo.insert!()

      user2 =
        %User{name: "random name 2", email: "#{Ecto.UUID.generate()}@email.com"}
        |> Repo.insert!()

      {:ok, account_in} = Accounts.generate_new_account(user1)
      {:ok, account_out} = Accounts.generate_new_account(user2)

      Operations.make_deposit(account_out.id, 1_000_00)

      {:ok, account_in: account_in, account_out: account_out}
    end

    test "fail if withdraw amount is greater than account balance", state do
      account_in = state[:account_in]
      account_out = state[:account_out]

      {:error, result} = Operations.make_transfer(account_in.id, account_out.id, 1_000_01)

      assert "must be greater than or equal to 0" in errors_on(result).balance

      account_in = from(a in Account, where: a.id == ^account_in.id) |> Repo.one()
      account_out = from(a in Account, where: a.id == ^account_out.id) |> Repo.one()

      assert account_in.balance == 0
      assert account_out.balance == 1_000_00
    end

    test "successfully make transfer with valid input", state do
      account_in = state[:account_in]
      account_out = state[:account_out]

      Operations.make_transfer(account_in.id, account_out.id, 300_00)

      account_in = from(a in Account, where: a.id == ^account_in.id) |> Repo.one()
      account_out = from(a in Account, where: a.id == ^account_out.id) |> Repo.one()

      assert account_in.balance == 300_00
      assert account_out.balance == 700_00
    end
  end
end
