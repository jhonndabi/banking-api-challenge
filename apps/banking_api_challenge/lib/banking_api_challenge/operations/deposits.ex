defmodule BankingApiChallenge.Operations.Deposits do
  alias BankingApiChallenge.Operations.Inputs.DepositInput
  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Operations.Schemas.Operation
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Repo

  def deposit(%DepositInput{} = input) do
    params = Map.from_struct(input)

    with %{valid?: true} <- DepositInput.changeset(params),
         {:ok, operation} <- do_deposit(input.account_id, input.amount) do
      {:ok, operation}
    else
      %{valid?: false} = changeset -> {:error, changeset}
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_deposit(account_id, amount) when is_integer(amount) and amount > 0 do
    fn ->
      with {:ok, account} <- Accounts.get_account_with_lock(account_id),
           {:ok, operation} <- build_deposit_operation(account, amount) |> Repo.insert(),
           {:ok, _account} <- Accounts.increase_balance(account, operation) do
        {:ok, operation}
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end
    |> Repo.transaction()
  end

  defp build_deposit_operation(%Account{} = account, amount) do
    Operation.changeset(%{
      operation_type: "deposit",
      target_account_id: account.id,
      amount: amount
    })
  end
end
