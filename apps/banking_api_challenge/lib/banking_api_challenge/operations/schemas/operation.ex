defmodule BankingApiChallenge.Operations.Schemas.Operation do
  @moduledoc """
  The operation schema.
  """
  use Ecto.Schema

  import Ecto.Changeset
  import BankingApiChallenge.Changesets

  alias BankingApiChallenge.Accounts.Schemas.Account

  @acceptable_operation_types ~w(deposit transfer withdraw)
  @required [:operation_type, :amount]
  @optional [:account_in, :account_out]

  @derive {Jason.Encoder, except: [:__meta__]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "operations" do
    field :operation_type, :integer
    field :amount, :integer

    belongs_to :account_in, Account
    belongs_to :account_out, Account

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> validate_inclusion(:operation_type, @acceptable_operation_types)
    |> validate_fields([:account_in, :account_out], fn changes, changeset ->
      if changes[:account_in] != nil || changes[:account_out] != nil do
        changeset
      else
        add_error(changeset, :account, "At least one account is required, on account_in or account_out")
      end
    end)
  end
end
