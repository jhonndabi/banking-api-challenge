defmodule BankingApiChallengeWeb.SignUpControllerTest do
  use BankingApiChallengeWeb.ConnCase, async: true

  alias BankingApiChallenge.SignUps
  alias BankingApiChallenge.SignUps.Inputs.SignUpInput

  describe "POST /api/v1/signups" do
    test "successfully sign up with valid input", %{conn: conn} do
      email = "#{Ecto.UUID.generate()}@email.com"

      input = %{
        name: "random name",
        email: email,
        email_confirmation: email,
        password_credential: %{
          password: "12345678"
        }
      }

      conn = post(conn, "/api/v1/signups", input)

      assert %{
               "user" => %{
                 "id" => _,
                 "name" => _,
                 "email" => _
               },
               "account" => %{
                 "id" => _,
                 "agency" => _,
                 "account_number" => _
               }
             } = json_response(conn, 200)
    end

    test "fail with 409 when email is already taken", ctx do
      email = "#{Ecto.UUID.generate()}@email.com"

      input = %SignUpInput{
        name: "random name",
        email: email,
        email_confirmation: email,
        password_credential: %{
          password: "12345678"
        }
      }

      SignUps.sign_up(input)
      input = Map.from_struct(input)

      assert ctx.conn
             |> post("/api/v1/signups", input)
             |> json_response(409) == %{
               "description" => "Email already taken",
               "type" => "conflict"
             }
    end
  end
end
