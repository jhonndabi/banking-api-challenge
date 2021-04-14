defmodule BankingApiChallengeWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BankingApiChallengeWeb.Telemetry,
      # Start the Endpoint (http/https)
      BankingApiChallengeWeb.Endpoint
      # Start a worker by calling: BankingApiChallengeWeb.Worker.start_link(arg)
      # {BankingApiChallengeWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BankingApiChallengeWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BankingApiChallengeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
