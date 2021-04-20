defmodule BankingApiChallenge.Operations.Transfers do
  alias BankingApiChallenge.Operations.Inputs.TransferInput
  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Operations.Schemas.Operation
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Repo

  def transfer(%TransferInput{} = input) do
    params = Map.from_struct(input)

    with %{valid?: true} <- TransferInput.changeset(params),
         {:ok, operation} <-
           do_transfer(input.source_account_id, input.target_account_id, input.amount) do
      {:ok, operation}
    else
      %{valid?: false} = changeset -> {:error, changeset}
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_transfer(source_account_id, target_account_id, amount)
       when is_integer(amount) and amount > 0 do
    fn ->
      with {:ok, source_account} <- Accounts.get_account_with_lock(source_account_id),
           {:ok, target_account} <- Accounts.get_account_with_lock(target_account_id),
           {:ok, operation} <-
             build_transfer_operation(target_account, source_account, amount) |> Repo.insert(),
           {:ok, _account} <- Accounts.decrease_balance(source_account, operation),
           {:ok, _account} <- Accounts.increase_balance(target_account, operation) do
        operation
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end
    |> Repo.transaction()
  end

  defp build_transfer_operation(%Account{} = source_account, %Account{} = target_account, amount) do
    Operation.changeset(%{
      operation_type: "transfer",
      source_account_id: source_account.id,
      target_account_id: target_account.id,
      amount: amount
    })
  end
end
