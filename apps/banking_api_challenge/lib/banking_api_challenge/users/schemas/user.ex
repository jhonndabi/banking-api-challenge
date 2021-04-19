defmodule BankingApiChallenge.Users.Schemas.User do
  @moduledoc """
  The user schema.
  """
  use Ecto.Schema

  import Ecto.Changeset
  import BankingApiChallenge.Changesets

  alias BankingApiChallenge.Accounts.Schemas.Account
  alias BankingApiChallenge.Credentials.Schemas.Password

  @required [:name, :email]
  @optional []

  @name_min_length 5

  @derive {Jason.Encoder, except: [:__meta__]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string
    field :email, :string

    has_one :password_credential, Password, on_replace: :update, on_delete: :delete_all
    has_one :account, Account

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required ++ @optional)
    |> cast_assoc(:password_credential, required: true)
    |> validate_required(@required)
    |> validate_length(:name, min: @name_min_length)
    |> validate_email(:email)
  end
end
