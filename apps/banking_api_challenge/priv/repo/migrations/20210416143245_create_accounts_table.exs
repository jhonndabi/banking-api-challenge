defmodule BankingApiChallenge.Repo.Migrations.CreateAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :agency, :integer, null: false
      add :account_number, :integer, null: false
      add :balance, :integer, null: false, default: 0

      add :user_id, references(:users, type: :uuid), null: false

      timestamps()
    end

    create index(:accounts, [:user_id])
    create constraint(:accounts, :balance_nonnegative, check: "balance >= 0")
    create unique_index(:accounts, [:agency, :account_number])
  end
end
