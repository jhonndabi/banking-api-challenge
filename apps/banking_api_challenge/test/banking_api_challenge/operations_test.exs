defmodule BankingApiChallenge.OperationsTest do
  use BankingApiChallenge.DataCase, async: true

  alias BankingApiChallenge.Operations.Inputs.DepositInput
  alias BankingApiChallenge.Operations.Inputs.WithdrawInput
  alias BankingApiChallenge.Operations.Inputs.TransferInput
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Operations
  alias BankingApiChallenge.Operations.Deposits
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
      |> Deposits.deposit()

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

      {:ok, target_account} = Accounts.generate_new_account(user1)
      {:ok, source_account} = Accounts.generate_new_account(user2)

      %DepositInput{
        account_id: source_account.id,
        amount: 1_000_00
      }
      |> Deposits.deposit()

      {:ok, source_account: source_account, target_account: target_account}
    end

    test "fail if transfer amount is greater than source account balance", state do
      source_account = state[:source_account]
      target_account = state[:target_account]

      {:error, result} =
        %TransferInput{
          source_account_id: source_account.id,
          target_account_id: target_account.id,
          amount: 1_000_01
        }
        |> Operations.make_transfer()

      assert "must be greater than or equal to 0" in errors_on(result).balance

      target_account = from(a in Account, where: a.id == ^target_account.id) |> Repo.one()
      source_account = from(a in Account, where: a.id == ^source_account.id) |> Repo.one()

      assert source_account.balance == 1_000_00
      assert target_account.balance == 0
    end

    test "successfully make transfer with valid input", state do
      source_account = state[:source_account]
      target_account = state[:target_account]

      %TransferInput{
        source_account_id: source_account.id,
        target_account_id: target_account.id,
        amount: 300_00
      }
      |> Operations.make_transfer()

      target_account = from(a in Account, where: a.id == ^target_account.id) |> Repo.one()
      source_account = from(a in Account, where: a.id == ^source_account.id) |> Repo.one()

      assert source_account.balance == 700_00
      assert target_account.balance == 300_00
    end
  end
end
