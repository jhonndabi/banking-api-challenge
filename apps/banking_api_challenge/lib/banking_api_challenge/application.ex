defmodule BankingApiChallenge.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      BankingApiChallenge.Repo,
      # Start a worker by calling: BankingApiChallenge.Worker.start_link(arg)
      # {BankingApiChallenge.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BankingApiChallenge.Supervisor)
  end
end
