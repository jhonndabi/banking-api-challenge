defmodule BankingApiChallenge.Operations.WithdrawalsTest do
  use BankingApiChallenge.DataCase, async: true

  alias BankingApiChallenge.Operations.Inputs.DepositInput
  alias BankingApiChallenge.Operations.Inputs.WithdrawalInput
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Operations.Withdrawals
  alias BankingApiChallenge.Operations.Deposits
  alias BankingApiChallenge.Users.Schemas.User
  alias BankingApiChallenge.Accounts.Schemas.Account

  describe "withdrawal/1" do
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

    test "fail if withdrawal amount is greater than account balance", state do
      account = state[:account]

      {:error, result} =
        %WithdrawalInput{
          account_id: account.id,
          amount: 1_000_01
        }
        |> Withdrawals.withdrawal()

      assert "must be greater than or equal to 0" in errors_on(result).balance

      query = from(a in Account, where: a.id == ^account.id)

      account = Repo.one(query)

      assert account.balance == 1_000_00
    end

    test "successfully make withdrawal with valid input", state do
      account = state[:account]

      %WithdrawalInput{
        account_id: account.id,
        amount: 250_00
      }
      |> Withdrawals.withdrawal()

      query = from(a in Account, where: a.id == ^account.id)

      account = Repo.one(query)

      assert account.balance == 750_00
    end
  end
end
