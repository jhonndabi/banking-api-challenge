defmodule BankingApiChallenge.Operations.Withdrawals do
  alias BankingApiChallenge.Operations.Inputs.WithdrawInput
  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Operations.Schemas.Operation
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Repo

  require Logger

  def withdrawal(%WithdrawInput{} = input) do
    fn ->
      with {:ok, account} <- Accounts.get_account_with_lock(input.account_id),
           {:ok, operation} <- create_withdrawal_operation(account, input.amount),
           {:ok, _account} <- Accounts.decrease_balance(account, operation) do
        operation
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end
    |> Repo.transaction()
    |> case do
      {:ok, operation} ->
        Logger.info("Succesfully withdrawn from your account")
        {:ok, operation}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_withdrawal_operation(%Account{} = account, amount) do
    %{
      operation_type: "withdraw",
      source_account_id: account.id,
      amount: amount
    }
    |> Operation.changeset()
    |> Repo.insert()
  end
end
