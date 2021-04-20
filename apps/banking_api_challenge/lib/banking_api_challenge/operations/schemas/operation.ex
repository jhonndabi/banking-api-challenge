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
  @optional []

  @derive {Jason.Encoder, except: [:__meta__, :source_account, :target_account]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "operations" do
    field :operation_type, :string
    field :amount, :integer

    belongs_to :source_account, Account
    belongs_to :target_account, Account

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required ++ @optional)
    |> cast_assoc(:target_account)
    |> cast_assoc(:source_account)
    |> validate_required(@required)
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> validate_inclusion(:operation_type, @acceptable_operation_types)
    |> validate_fields([:target_account, :source_account], &check_operation_has_at_least_one_account/2)
  end

  defp check_operation_has_at_least_one_account(changes, changeset) do
    if changes[:target_account] != nil || changes[:source_account] != nil do
      changeset
    else
      add_error(
        changeset,
        :account,
        "At least one account is required, on target_account or source_account"
      )
    end
  end
end
