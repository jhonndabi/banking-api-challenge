defmodule BankingApiChallenge.Changesets do
  @moduledoc """
  Validation functions to ease building changesets.
  """

  import Ecto.Changeset

  @doc """
  Given a valid changeset, applies function with the changes of the given fields.
  """
  @spec validate_fields(
          Ecto.Changeset.t(),
          list(atom()),
          (list(atom()), Ecto.Changeset.t() -> Ecto.Changeset.t())
        ) :: Ecto.Changeset.t()
  def validate_fields(%{valid?: false} = changeset, _fields, _function) do
    changeset
  end

  def validate_fields(changeset, fields, function) do
    changes = Enum.map(fields, fn field -> {field, get_change(changeset, field)} end)
    function.(changes, changeset)
  end
end
