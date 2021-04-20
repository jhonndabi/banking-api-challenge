defmodule BankingApiChallenge.Operations.Transfers do
  alias BankingApiChallenge.Operations.Inputs.TransferInput
  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Operations.Schemas.Operation
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Repo

  require Logger

  def transfer(%TransferInput{} = input) do
    fn ->
      with {:ok, source_account} <- Accounts.get_account_with_lock(input.source_account_id),
           {:ok, target_account} <- Accounts.get_account_with_lock(input.target_account_id),
           {:ok, operation} <-
             create_transfer_operation(source_account, target_account, input.amount),
           {:ok, _account} <- Accounts.decrease_balance(source_account, operation),
           {:ok, _account} <- Accounts.increase_balance(target_account, operation) do
        operation
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end
    |> Repo.transaction()
    |> case do
      {:ok, operation} ->
        Logger.info("Succesfully transfered from your account")
        {:ok, operation}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_transfer_operation(%Account{} = source_account, %Account{} = target_account, amount) do
    %{
      operation_type: "transfer",
      source_account_id: source_account.id,
      target_account_id: target_account.id,
      amount: amount
    }
    |> Operation.changeset()
    |> Repo.insert()
  end
end
