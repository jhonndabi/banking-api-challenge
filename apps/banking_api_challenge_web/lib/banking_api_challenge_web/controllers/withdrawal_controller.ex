defmodule BankingApiChallengeWeb.WithdrawalController do
  @moduledoc """
  Actions related to the withdrawal resource.
  """
  use BankingApiChallengeWeb, :controller

  alias BankingApiChallenge.Operations.Withdrawals
  alias BankingApiChallenge.Operations.Inputs.WithdrawalInput
  alias BankingApiChallenge.InputValidation

  @doc """
  Make withdrawal operation action.
  """
  def withdrawal(conn, params) do
    with {:ok, input} <- InputValidation.cast_and_apply(params, WithdrawalInput),
         {:ok, user} <- Withdrawals.withdrawal(input) do
      send_json(conn, 200, user)
    else
      {:error, %Ecto.Changeset{errors: errors}} ->
        msg = %{
          type: "bad_input",
          description: "Invalid input",
          details: changeset_errors_to_details(errors)
        }

        send_json(conn, 400, msg)
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
