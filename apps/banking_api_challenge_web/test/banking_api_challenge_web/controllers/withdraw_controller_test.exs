defmodule BankingApiChallengeWeb.WithdrawControllerTest do
  use BankingApiChallengeWeb.ConnCase, async: true

  alias BankingApiChallenge.Operations.Deposits
  alias BankingApiChallenge.Accounts
  alias BankingApiChallenge.Users.Schemas.User
  alias BankingApiChallenge.Operations.Inputs.DepositInput
  alias BankingApiChallenge.Repo

  describe "POST /api/v1/withdraws" do
    setup do
      user =
        %User{name: "random name", email: "#{Ecto.UUID.generate()}@email.com"}
        |> Repo.insert!()

      {:ok, account} = Accounts.generate_new_account(user)

      %DepositInput{
        account_id: account.id,
        amount: 1_000_00
      }
      |> Deposits.deposit()

      {:ok, account: account}
    end

    test "fail with 400 when account balance is less than withdraw amount", %{
      conn: conn,
      account: account
    } do
      input = %{
        account_id: account.id,
        amount: 1_000_01
      }

      conn = post(conn, "/api/v1/withdraws", input)

      assert %{
               "description" => "Invalid input",
               "type" => "bad_input",
               "details" => %{"balance" => "must be greater than or equal to %{number}"}
             } = json_response(conn, 400)
    end

    test "successfully withdraw with valid input", %{conn: conn, account: account} do
      input = %{
        account_id: account.id,
        amount: 489_99
      }

      conn = post(conn, "/api/v1/withdraws", input)

      assert %{
               "operation_type" => "withdraw",
               "amount" => 489_99
             } = json_response(conn, 200)
    end
  end
end
