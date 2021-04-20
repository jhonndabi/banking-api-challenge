defmodule BankingApiChallengeWeb.SignUpController do
  @moduledoc """
  Actions related to the sign up resource.
  """
  use BankingApiChallengeWeb, :controller

  alias BankingApiChallenge.SignUps
  alias BankingApiChallenge.SignUps.Inputs.SignUpInput
  alias BankingApiChallenge.InputValidation

  @doc """
  Sign up user action.
  """
  def sign_up(conn, params) do
    with {:ok, input} <- InputValidation.cast_and_apply(params, SignUpInput),
         {:ok, user_and_account} <- SignUps.sign_up(input) do
      send_json(conn, 200, user_and_account)
    else
      {:error, %Ecto.Changeset{errors: errors}} ->
        msg = %{
          type: "bad_input",
          description: "Invalid input",
          details: changeset_errors_to_details(errors)
        }

        send_json(conn, 400, msg)

      {:error, :email_conflict} ->
        msg = %{type: "conflict", description: "Email already taken"}
        send_json(conn, 409, msg)
    end
  end

  defp send_json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  defp changeset_errors_to_details(errors) do
    errors
    |> Enum.map(fn {key, {message, _opts}} -> {key, message} end)
    |> Map.new()
  end
end
