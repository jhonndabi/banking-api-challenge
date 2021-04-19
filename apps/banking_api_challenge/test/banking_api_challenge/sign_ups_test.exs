defmodule BankingApiChallenge.SignUpsTest do
  use BankingApiChallenge.DataCase, async: true

  alias BankingApiChallenge.SignUps
  alias BankingApiChallenge.SignUps.Inputs.SignUpInput
  alias BankingApiChallenge.Users.Schemas.User

  describe "sign_up/1" do
    test "fail if email is already taken" do
      email = "taken@email.com"
      Repo.insert!(%User{name: "random name", email: email})

      input = %SignUpInput{
        name: "random name",
        email: email,
        email_confirmation: email,
        password_credential: %{
          password: "12345678"
        }
      }

      assert {:error, :email_conflict} == SignUps.sign_up(input)
    end

    test "successfully sign up with valid input" do
      email = "#{Ecto.UUID.generate()}@email.com"

      input = %SignUpInput{
        name: "random name",
        email: email,
        email_confirmation: email,
        password_credential: %{
          password: "12345678"
        }
      }

      assert {:ok, _user} = SignUps.sign_up(input)

      query = from(u in User, preload: [:password_credential, :account], where: u.email == ^email)

      user = Repo.one(query)

      assert user.account.balance == 1_000_00
    end
  end
end
