defmodule BankingApiChallenge.Operations do
  alias BankingApiChallenge.Operations.Inputs.WithdrawInput
  alias BankingApiChallenge.Operations.Inputs.TransferInput
  alias BankingApiChallenge.Operations.Withdrawals
  alias BankingApiChallenge.Operations.Transfers

  def make_withdraw(%WithdrawInput{} = input) do
    Withdrawals.withdrawal(input)
  end

  def make_transfer(%TransferInput{} = input) do
    Transfers.transfer(input)
  end
end
