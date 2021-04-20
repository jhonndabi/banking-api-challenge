defmodule BankingApiChallengeWeb.TransferController do
  @moduledoc """
  Actions related to the transfer resource.
  """
  use BankingApiChallengeWeb, :controller

  alias BankingApiChallenge.Operations.Transfers
  alias BankingApiChallenge.Operations.Inputs.TransferInput
  alias BankingApiChallenge.InputValidation

  @doc """
  Make transfer operation action.
  """
  def transfer(conn, params) do
    with {:ok, input} <- InputValidation.cast_and_apply(params, TransferInput),
         {:ok, user} <- Transfers.transfer(input) do
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
