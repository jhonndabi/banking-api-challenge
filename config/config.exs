# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :banking_api_challenge,
  ecto_repos: [BankingApiChallenge.Repo]

config :banking_api_challenge_web,
  ecto_repos: [BankingApiChallenge.Repo],
  generators: [context_app: :banking_api_challenge]

# Configures the endpoint
config :banking_api_challenge_web, BankingApiChallengeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "a0VFCfYnlDyKe9GUSbh2hxwJkDb3s7PkIfHFixidvtlSoL88+5G7XqUloowLAkWW",
  render_errors: [view: BankingApiChallengeWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: BankingApiChallenge.PubSub,
  live_view: [signing_salt: "YQnGOSTC"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
