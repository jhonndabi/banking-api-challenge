defmodule BankingApiChallenge.OperationsTest do
  use BankingApiChallenge.DataCase, async: true

  alias BankingApiChallenge.Operations.Inputs.DepositInput
  alias BankingApiChallenge.Operations.Inputs.WithdrawInput
  alias BankingApiChallenge.Operations.Inputs.TransferInput
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

      %DepositInput{
        account_id: account.id,
        amount: 1_000_00
      }
      |> Operations.make_deposit()

      {:ok, account: account}
    end

    test "fail if withdraw amount is greater than account balance", state do
      account = state[:account]

      {:error, result} =
        %WithdrawInput{
          account_id: account.id,
          amount: 1_000_01
        }
        |> Operations.make_withdraw()

      assert "must be greater than or equal to 0" in errors_on(result).balance

      query = from(a in Account, where: a.id == ^account.id)

      account = Repo.one(query)

      assert account.balance == 1_000_00
    end

    test "successfully make withdraw with valid input", state do
      account = state[:account]

      %WithdrawInput{
        account_id: account.id,
        amount: 250_00
      }
      |> Operations.make_withdraw()

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

      %DepositInput{
        account_id: account_out.id,
        amount: 1_000_00
      }
      |> Operations.make_deposit()

      {:ok, account_in: account_in, account_out: account_out}
    end

    test "fail if withdraw amount is greater than account balance", state do
      account_in = state[:account_in]
      account_out = state[:account_out]

      {:error, result} =
        %TransferInput{
          account_in_id: account_in.id,
          account_out_id: account_out.id,
          amount: 1_000_01
        }
        |> Operations.make_transfer()

      assert "must be greater than or equal to 0" in errors_on(result).balance

      account_in = from(a in Account, where: a.id == ^account_in.id) |> Repo.one()
      account_out = from(a in Account, where: a.id == ^account_out.id) |> Repo.one()

      assert account_in.balance == 0
      assert account_out.balance == 1_000_00
    end

    test "successfully make transfer with valid input", state do
      account_in = state[:account_in]
      account_out = state[:account_out]

      %TransferInput{
        account_in_id: account_in.id,
        account_out_id: account_out.id,
        amount: 300_00
      }
      |> Operations.make_transfer()

      account_in = from(a in Account, where: a.id == ^account_in.id) |> Repo.one()
      account_out = from(a in Account, where: a.id == ^account_out.id) |> Repo.one()

      assert account_in.balance == 300_00
      assert account_out.balance == 700_00
    end
  end
end
