defmodule BankingApiChallenge.SignUps.Inputs.SignUpInput do
  @moduledoc """
  SignUp data
  """
  use Ecto.Schema

  import Ecto.Changeset
  import BankingApiChallenge.Changesets

  @user_required_fields [:name, :email, :email_confirmation]
  @password_credentials_required_fields [:password]

  @name_min_length 5
  @password_min_length 8

  @primary_key false
  embedded_schema do
    field :name, :string
    field :email, :string
    field :email_confirmation, :string

    embeds_one :password_credentials, PasswordCredentials, on_replace: :update do
      field :password, :string
    end
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @user_required_fields)
    |> cast_embed(:password_credentials, with: &changeset_password_credentials/2, required: true)
    |> validate_required(@user_required_fields)
    |> validate_length(:name, min: @name_min_length)
    |> validate_email(:email)
    |> validate_email(:email_confirmation)
    |> validate_fields([:email, :email_confirmation], fn changes, changeset ->
      if changes[:email] == changes[:email_confirmation] do
        changeset
      else
        add_error(changeset, :email_and_confirmation, "Email and confirmation must be the same")
      end
    end)
  end

  defp changeset_password_credentials(model, params) do
    model
    |> cast(params, @password_credentials_required_fields)
    |> validate_required(@password_credentials_required_fields)
    |> validate_length(:password, min: @password_min_length)
  end
end
