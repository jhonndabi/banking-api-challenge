defmodule BankingApiChallenge.SignUps do
  @moduledoc """
  Domain public functions about the sign up context.
  """

  alias BankingApiChallenge.Operations.Inputs.DepositInput
  alias BankingApiChallenge.Users.Schemas.User
  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.SignUps.Inputs.SignUpInput
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Operations
  alias BankingApiChallenge.Users
  alias BankingApiChallenge.Repo
  alias BankingApiChallenge.InputValidation

  @initial_deposit_amount 1_000_00

  def sign_up(%SignUpInput{} = input) do
    params = %{
      name: input.name,
      email: input.email,
      email_confirmation: input.email_confirmation,
      password_credential: %{
        password: input.password_credential.password
      }
    }

    with {:ok, user} <- InputValidation.cast_and_apply(params, User),
         {:ok, user_and_account} <- do_sign_up(user) do
      user_and_account
    else
      %{valid?: false} = changeset -> {:error, changeset}
      {:error, reason} -> {:error, reason}
    end
  rescue
    Ecto.ConstraintError ->
      {:error, :email_conflict}
  end

  defp do_sign_up(%User{} = user) do
    fn ->
      with {:ok, user} <- Users.create_user(user),
           {:ok, account} <- Accounts.generate_new_account(user),
           {:ok, _deposit} <- make_initial_deposit(account) do
        {:ok,
         %{
           user: user,
           account: %{
             id: account.id,
             agency: account.agency,
             account_number: account.account_number
           }
         }}
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end
    |> Repo.transaction()
  end

  defp make_initial_deposit(%Account{} = account) do
    %DepositInput{
      account_id: account.id,
      amount: @initial_deposit_amount
    }
    |> Operations.make_deposit()
  end
end
