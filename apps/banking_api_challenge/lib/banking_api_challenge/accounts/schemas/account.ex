defmodule BankingApiChallenge.Accounts.Schemas.Account do
  @moduledoc """
  The account schema.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias BankingApiChallenge.Users.Schemas.User
  alias BankingApiChallenge.Operations.Schemas.Operation

  @required [:agency, :account_number, :balance, :user_id]
  @optional []

  @derive {Jason.Encoder, except: [:__meta__, :source_operations, :target_operations, :user]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :agency, :integer
    field :account_number, :integer
    field :balance, :integer, default: 0, redact: true

    has_many :source_operations, Operation, foreign_key: :source_account_id
    has_many :target_operations, Operation, foreign_key: :target_account_id

    belongs_to :user, User

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> unique_constraint([:agency, :account_number])
  end
end
