defmodule BankingApiChallenge.Repo.Migrations.CreateOperationsTable do
  use Ecto.Migration

  def change do
    create table(:operations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :operation_type, :string, null: false
      add :amount, :integer, null: false, default: 0

      add :source_account_id, references(:accounts, type: :uuid)
      add :target_account_id, references(:accounts, type: :uuid)

      timestamps()
    end

    create index(:operations, [:target_account_id, :source_account_id])
    create constraint(:operations, :amount_nonnegative, check: "amount >= 0")
  end
end
