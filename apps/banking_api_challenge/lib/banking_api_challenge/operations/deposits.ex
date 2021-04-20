defmodule BankingApiChallenge.Operations.Deposits do
  alias BankingApiChallenge.Operations.Inputs.DepositInput
  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Operations.Schemas.Operation
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Repo

  def deposit(%DepositInput{} = input) do
    fn ->
      with {:ok, account} <- Accounts.get_account_with_lock(input.account_id),
           {:ok, operation} <- create_deposit_operation(account, input.amount),
           {:ok, _account} <- Accounts.increase_balance(account, operation) do
        {:ok, operation}
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end
    |> Repo.transaction()
    |> case do
      {:ok, operation} ->
        {:ok, operation}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_deposit_operation(%Account{} = account, amount) do
    %{
      operation_type: "deposit",
      target_account_id: account.id,
      amount: amount
    }
    |> Operation.changeset()
    |> Repo.insert()
  end
end
