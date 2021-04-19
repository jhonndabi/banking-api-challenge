defmodule BankingApiChallenge.SignUps do
  @moduledoc """
  Domain public functions about the sign up context.
  """

  alias BankingApiChallenge.Users.Schemas.User
  alias BankingApiChallenge.SignUps.Inputs.SignUpInput
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Operations
  alias BankingApiChallenge.Repo

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

    with %{valid?: true} = changeset <- User.changeset(params),
         {:ok, user} <- do_sign_up(changeset) do
      {:ok, user}
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  rescue
    Ecto.ConstraintError ->
      {:error, :email_conflict}
  end

  defp do_sign_up(changeset) do
    fn ->
      with {:ok, user} <- Repo.insert(changeset),
           {:ok, account} <- Accounts.generate_new_account(user),
           {:ok, deposit} <- Operations.make_deposit(account.id, @initial_deposit_amount) do
        deposit
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end
    |> Repo.transaction()
  end
end
