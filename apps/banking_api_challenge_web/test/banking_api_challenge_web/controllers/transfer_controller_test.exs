defmodule BankingApiChallengeWeb.TransferControllerTest do
  use BankingApiChallengeWeb.ConnCase, async: true

  alias BankingApiChallenge.Operations
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Users.Schemas.User
  alias BankingApiChallenge.Operations.Inputs.DepositInput
  alias BankingApiChallenge.Repo

  describe "POST /api/v1/transfer" do
    setup do
      source_user = %User{name: "source name", email: "source@email.com"} |> Repo.insert!()
      target_user = %User{name: "target name", email: "target@email.com"} |> Repo.insert!()

      {:ok, account_source} = Accounts.generate_new_account(source_user)
      {:ok, account_target} = Accounts.generate_new_account(target_user)

      %DepositInput{
        account_id: account_source.id,
        amount: 1_000_00
      }
      |> Operations.make_deposit()

      {:ok, accounts: %{source: account_source, target: account_target}}
    end

    test "fail with 400 when account balance is less than transfer amount", %{conn: conn, accounts: accounts} do
      input = %{
        account_source_id: accounts.source.id,
        account_target_id: accounts.target.id,
        amount: 1_000_01
      }

      conn = post(conn, "/api/v1/transfer", input)

      assert %{
              "description" => "Invalid input",
              "type" => "bad_input",
              "details" => %{"balance" => "must be greater than or equal to %{number}"}
            } = json_response(conn, 400)
    end

    test "successfully transfer with valid input", %{conn: conn, accounts: accounts} do
      input = %{
        account_source_id: accounts.source.id,
        account_target_id: accounts.target.id,
        amount: 299_99
      }

      conn = post(conn, "/api/v1/transfer", input)

      assert %{
              "operation_type" => "transfer",
              "amount" => 299_99,
            } = json_response(conn, 200)
    end
  end
end
