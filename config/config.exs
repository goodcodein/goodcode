# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :goodcode,
  namespace: GC


# Configures the endpoint
config :goodcode, GC.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "o78vqZoaFZpGqMNMxgf2Em73nGKDsWN+3i4L/8KHizWyn5sz3+M85wU/+gDrmILV",
  render_errors: [view: GC.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GC.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
