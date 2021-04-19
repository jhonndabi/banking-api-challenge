defmodule BankingApiChallenge.Repo.Migrations.CreateOperationsTable do
  use Ecto.Migration

  def change do
    create table(:operations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :operation_type, :string, null: false
      add :amount, :integer, null: false, default: 0

      add :account_source_id, references(:accounts, type: :uuid)
      add :account_target_id, references(:accounts, type: :uuid)

      timestamps()
    end

    create index(:operations, [:account_target_id, :account_source_id])
    create constraint(:operations, :amount_nonnegative, check: "amount >= 0")
  end
end
