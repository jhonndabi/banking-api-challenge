defmodule BankingApiChallenge.Operations.Inputs.DepositInput do
  @moduledoc """
  Deposit operation data
  """
  use Ecto.Schema

  import Ecto.Changeset

  @required_fields [:account_id, :amount]

  @primary_key false
  embedded_schema do
    field :operation_type, :string, default: "deposit"
    field :account_id, :binary_id
    field :amount, :integer
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_number(:amount, greater_than: 0)
  end
end
