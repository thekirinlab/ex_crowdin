defmodule ExCrowdin.Config do
  @moduledoc """
  Utility that handles interaction with the application's configuration
  """

  @doc """
  In config.exs your implicit or expicit configuration is:
      config ex_:crowdin, json_library: Poison # defaults to Jason but can be configured to Poison
  """
  @spec json_library() :: module
  def json_library do
    resolve(:json_library, Jason)
  end

  @doc """
  In config.exs, use a string, a function or a tuple:
      config :ex_crowdin, access_token: System.get_env("CROWDIN_ACCESS_TOKEN")

  or:
      config :ex_crowdin, access_token: {:system, "CROWDIN_ACCESS_TOKEN"}

  or:
      config :ex_crowdin, access_token: {MyApp.Config, :crowdin_access_token, []}
  """
  def access_token do
    resolve(:access_token)
  end

  @doc """
  In config.exs, use a string, a function or a tuple:
      config :ex_crowdin, project_id: System.get_env("CROWDIN_PROJECT_ID")

  or:
      config :ex_crowdin, project_id: {:system, "CROWDIN_PROJECT_ID"}

  or:
      config :ex_crowdin, project_id: {MyApp.Config, :crowdin_project_id, []}
  """
  def project_id do
    resolve(:project_id)
  end

  @doc """
  Resolves the given key from the application's configuration returning the
  wrapped expanded value. If the value was a function it get's evaluated, if
  the value is a touple of three elements it gets applied.
  """
  @spec resolve(atom, any) :: any
  def resolve(key, default \\ nil)

  def resolve(key, default) when is_atom(key) do
    Application.get_env(:ex_crowdin, key, default)
    |> expand_value()
  end

  def resolve(key, _) do
    raise(
      ArgumentError,
      message: "#{__MODULE__} expected key '#{key}' to be an atom"
    )
  end

  defp expand_value({:system, env})
       when is_binary(env) do
    System.get_env(env)
  end

  defp expand_value({module, function, args})
       when is_atom(function) and is_list(args) do
    apply(module, function, args)
  end

  defp expand_value(value) when is_function(value) do
    value.()
  end

  defp expand_value(value), do: value
end
