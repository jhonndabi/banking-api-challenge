defmodule BankingApiChallenge.Operations.Withdrawals do
  alias BankingApiChallenge.Operations.Inputs.WithdrawInput
  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Operations.Schemas.Operation
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Repo

  require Logger

  def withdrawal(%WithdrawInput{} = input) do
    params = Map.from_struct(input)

    with %{valid?: true} <- WithdrawInput.changeset(params),
         {:ok, operation} <- do_withdrawal(input.account_id, input.amount) do
      Logger.info("Succesfully withdrawn from your account")

      {:ok, operation}
    else
      %{valid?: false} = changeset -> {:error, changeset}
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_withdrawal(account_id, amount) when is_integer(amount) and amount > 0 do
    fn ->
      with {:ok, account} <- Accounts.get_account_with_lock(account_id),
           {:ok, operation} <- build_withdrawal_operation(account, amount) |> Repo.insert(),
           {:ok, _account} <- Accounts.decrease_balance(account, operation) do
        operation
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end
    |> Repo.transaction()
  end

  defp build_withdrawal_operation(%Account{} = account, amount) do
    Operation.changeset(%{
      operation_type: "withdraw",
      source_account_id: account.id,
      amount: amount
    })
  end
end
