defmodule BankingApiChallenge.Operations do
  alias BankingApiChallenge.Operations.Inputs.TransferInput
  alias BankingApiChallenge.Operations.Transfers

  def make_transfer(%TransferInput{} = input) do
    Transfers.transfer(input)
  end
end
