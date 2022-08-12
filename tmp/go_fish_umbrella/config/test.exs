import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :go_fish_web, GoFishWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "KsjMRAXHacQObf1W3Rm4wVRY1aqqWCo2eQ1jMBbanznrwxw/A/MO0AiZ7T73zftC",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# In test we don't send emails.
config :go_fish, GoFish.Mailer, adapter: Swoosh.Adapters.Test

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
