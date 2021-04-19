defmodule BankingApiChallenge.Operations do
  import Ecto.Query

  alias BankingApiChallenge.Operations.Inputs.DepositInput
  alias BankingApiChallenge.Operations.Inputs.WithdrawInput
  alias BankingApiChallenge.Operations.Inputs.TransferInput
  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Operations.Schemas.Operation
  alias BankingApiChallenge.Repo

  def make_deposit(%DepositInput{} = input) do
    params = Map.from_struct(input)

    with %{valid?: true} <- DepositInput.changeset(params),
         {:ok, operation} <- do_make_deposit(input.account_id, input.amount) do
      {:ok, operation}
    else
      %{valid?: false} = changeset -> {:error, changeset}
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_make_deposit(account_id, amount) when is_integer(amount) and amount > 0 do
    fn ->
      with {:ok, account} <- get_account_with_lock(account_id),
           {:ok, operation} <- build_deposit_operation(account, amount) |> Repo.insert(),
           {:ok, _account} <- increase_balance(account, operation.amount) do
        {:ok, operation}
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end
    |> Repo.transaction()
  end

  def make_withdraw(%WithdrawInput{} = input) do
    params = Map.from_struct(input)

    with %{valid?: true} <- WithdrawInput.changeset(params),
         {:ok, operation} <- do_make_withdraw(input.account_id, input.amount) do
      {:ok, operation}
    else
      %{valid?: false} = changeset -> {:error, changeset}
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_make_withdraw(account_id, amount) when is_integer(amount) and amount > 0 do
    fn ->
      with {:ok, account} <- get_account_with_lock(account_id),
           {:ok, operation} <- build_withdraw_operation(account, amount) |> Repo.insert(),
           {:ok, _account} <- decrease_balance(account, amount) do
        operation
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end
    |> Repo.transaction()
  end

  def make_transfer(%TransferInput{} = input) do
    params = Map.from_struct(input)

    with %{valid?: true} <- TransferInput.changeset(params),
         {:ok, operation} <-
           do_make_transfer(input.account_source_id, input.account_target_id, input.amount) do
      {:ok, operation}
    else
      %{valid?: false} = changeset -> {:error, changeset}
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_make_transfer(account_source_id, account_target_id, amount)
       when is_integer(amount) and amount > 0 do
    fn ->
      with {:ok, account_source} <- get_account_with_lock(account_source_id),
           {:ok, account_target} <- get_account_with_lock(account_target_id),
           {:ok, operation} <-
             build_transfer_operation(account_target, account_source, amount) |> Repo.insert(),
           {:ok, _account} <- decrease_balance(account_source, amount),
           {:ok, _account} <- increase_balance(account_target, amount) do
        operation
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end
    |> Repo.transaction()
  end

  defp get_account_with_lock(account_id) do
    account =
      Account
      |> lock("FOR UPDATE")
      |> Repo.get(account_id)

    case account do
      nil -> {:error, :account_not_found}
      _ -> {:ok, account}
    end
  end

  defp increase_balance(%Account{} = account, amount) when is_integer(amount) and amount > 0 do
    account
    |> Account.changeset(%{balance: account.balance + amount})
    |> Repo.update()
  end

  defp decrease_balance(%Account{} = account, amount) when is_integer(amount) and amount > 0 do
    account
    |> Account.changeset(%{balance: account.balance - amount})
    |> Repo.update()
  end

  defp build_deposit_operation(%Account{} = account, amount) do
    Operation.changeset(%{
      operation_type: "deposit",
      account_target: Map.from_struct(account),
      amount: amount
    })
  end

  defp build_withdraw_operation(%Account{} = account, amount) do
    Operation.changeset(%{
      operation_type: "withdraw",
      account_source: Map.from_struct(account),
      amount: amount
    })
  end

  defp build_transfer_operation(%Account{} = account_source, %Account{} = account_target, amount) do
    Operation.changeset(%{
      operation_type: "transfer",
      account_source: Map.from_struct(account_source),
      account_target: Map.from_struct(account_target),
      amount: amount
    })
  end
end
