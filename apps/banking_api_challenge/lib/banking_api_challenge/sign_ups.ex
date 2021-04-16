defmodule BankingApiChallenge.SignUps do
  @moduledoc """
  Domain public functions about the sign up context.
  """

  alias BankingApiChallenge.Users.Schemas.User
  alias BankingApiChallenge.SignUps.Inputs.SignUpInput
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Operations
  alias BankingApiChallenge.Repo
  alias Ecto.Multi

  @initial_deposit_amount 1_000_00

  def sign_up(%SignUpInput{} = input) do
    with %{valid?: true} = changeset <- User.changeset(input),
          {:ok, user} <- %{create_user: do_sign_up(changeset)} do
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
    Multi.new()
    |> Multi.run(:create_user, fn _changes, _ ->
      Repo.insert(changeset)
    end)
    |> Multi.run(:create_account, fn changes, _ ->
      Accounts.generate_new_account(changes.create_user)
    end)
    |> Multi.run(:make_initial_deposit, fn changes, _ ->
      Operations.make_deposit(changes.create_account, @initial_deposit_amount)
    end)
    |> Repo.transaction()
  end
end
