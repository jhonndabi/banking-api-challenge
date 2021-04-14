defmodule BankingApiChallenge.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      BankingApiChallenge.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: BankingApiChallenge.PubSub}
      # Start a worker by calling: BankingApiChallenge.Worker.start_link(arg)
      # {BankingApiChallenge.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BankingApiChallenge.Supervisor)
  end
end
