defmodule BankingApiChallenge.SignUps.Inputs.SignUpInput do
  @moduledoc """
  SignUp data
  """
  use Ecto.Schema

  import Ecto.Changeset
  import BankingApiChallenge.Changesets

  @user_required_fields [:name, :email, :email_confirmation]
  @password_credential_required_fields [:password]

  @name_min_length 5
  @password_min_length 8

  @primary_key false
  embedded_schema do
    field :name, :string
    field :email, :string
    field :email_confirmation, :string

    embeds_one :password_credential, PasswordCredentials, on_replace: :update do
      field :password, :string
    end
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @user_required_fields)
    |> cast_embed(:password_credential, with: &changeset_password_credential/2, required: true)
    |> validate_required(@user_required_fields)
    |> validate_length(:name, min: @name_min_length)
    |> validate_fields([:email, :email_confirmation], &validate_email_confirmation/2)
  end

  defp changeset_password_credential(model, params) do
    model
    |> cast(params, @password_credential_required_fields)
    |> validate_required(@password_credential_required_fields)
    |> validate_length(:password, min: @password_min_length)
  end

  defp validate_email_confirmation(changes, changeset) do
    if changes[:email] == changes[:email_confirmation] do
      changeset
    else
      add_error(changeset, :email_and_confirmation, "Email and email confirmation must be the same")
    end
  end
end
