defmodule BankingApiChallenge.Operations do
  import Ecto.Query

  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Operations.Schemas.Operation
  alias BankingApiChallenge.Repo

  def make_deposit(account_id, amount) when is_integer(amount) and amount > 0 do
    fn ->
      with {:ok, account} <- get_account_with_lock(account_id),
           {:ok, operation} <- build_deposit_operation(account, amount) |> Repo.insert(),
           {:ok, _account} <- increase_balance(account, operation.amount) do
        operation
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end
    |> Repo.transaction()
  end

  def make_withdraw(account_id, amount) when is_integer(amount) and amount > 0 do
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

  def make_transfer(account_in_id, account_out_id, amount) when is_integer(amount) and amount > 0 do
    fn ->
      with {:ok, account_in} <- get_account_with_lock(account_in_id),
           {:ok, account_out} <- get_account_with_lock(account_out_id),
           {:ok, operation} <- build_transfer_operation(account_in, account_out, amount) |> Repo.insert(),
           {:ok, _account} <- increase_balance(account_in, amount),
           {:ok, _account} <- decrease_balance(account_out, amount) do
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
      account_in: Map.from_struct(account),
      amount: amount
    })
  end

  defp build_withdraw_operation(%Account{} = account, amount) do
    Operation.changeset(%{
      operation_type: "withdraw",
      account_out: Map.from_struct(account),
      amount: amount
    })
  end

  defp build_transfer_operation(%Account{} = account_in, %Account{} = account_out, amount) do
    Operation.changeset(%{
      operation_type: "transfer",
      account_in: Map.from_struct(account_in),
      account_out: Map.from_struct(account_out),
      amount: amount
    })
  end
end
