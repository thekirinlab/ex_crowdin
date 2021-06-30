use Mix.Config

# for testing with real access token
config :ex_crowdin,
  project_id: {:system, "CROWDIN_PROJECT_ID"},
  access_token: {:system, "CROWDIN_ACCESS_TOKEN"}
