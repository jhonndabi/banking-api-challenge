defmodule BankingApiChallenge.Operations.Inputs.TransferInput do
  @moduledoc """
  Transfer operation data
  """
  use Ecto.Schema

  import Ecto.Changeset

  @required_fields [:account_in_id, :account_out_id, :amount]

  @primary_key false
  embedded_schema do
    field :operation_type, :string, default: "transfer"
    field :account_in_id, :binary_id
    field :account_out_id, :binary_id
    field :amount, :integer
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_number(:amount, greater_than: 0)
  end
end
