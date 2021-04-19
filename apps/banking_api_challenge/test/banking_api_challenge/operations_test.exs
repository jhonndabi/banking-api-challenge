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

      {:ok, account_target} = Accounts.generate_new_account(user1)
      {:ok, account_source} = Accounts.generate_new_account(user2)

      %DepositInput{
        account_id: account_source.id,
        amount: 1_000_00
      }
      |> Operations.make_deposit()

      {:ok, account_source: account_source, account_target: account_target}
    end

    test "fail if transfer amount is greater than source account balance", state do
      account_source = state[:account_source]
      account_target = state[:account_target]

      {:error, result} =
        %TransferInput{
          account_source_id: account_source.id,
          account_target_id: account_target.id,
          amount: 1_000_01
        }
        |> Operations.make_transfer()

      assert "must be greater than or equal to 0" in errors_on(result).balance

      account_target = from(a in Account, where: a.id == ^account_target.id) |> Repo.one()
      account_source = from(a in Account, where: a.id == ^account_source.id) |> Repo.one()

      assert account_source.balance == 1_000_00
      assert account_target.balance == 0
    end

    test "successfully make transfer with valid input", state do
      account_source = state[:account_source]
      account_target = state[:account_target]

      %TransferInput{
        account_source_id: account_source.id,
        account_target_id: account_target.id,
        amount: 300_00
      }
      |> Operations.make_transfer()

      account_target = from(a in Account, where: a.id == ^account_target.id) |> Repo.one()
      account_source = from(a in Account, where: a.id == ^account_source.id) |> Repo.one()

      assert account_source.balance == 700_00
      assert account_target.balance == 300_00
    end
  end
end
