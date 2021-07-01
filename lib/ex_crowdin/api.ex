defmodule ExCrowdin.API do
  @moduledoc """
  Utilities for interacting with the Crowdin API v2.
  """

  alias ExCrowdin.{Config, Request}

  @api_path "https://api.crowdin.com/api/v2"

  @type method :: :get | :post | :put | :delete | :patch
  @type headers :: %{String.t() => String.t()} | %{}
  @type body :: iodata() | {:multipart, list()}

  @request_module if Mix.env() == :test, do: ExCrowdin.RequestMock, else: Request

  @doc """
  In config.exs your implicit or expicit configuration is:
      config ex_:crowdin, json_library: Poison # defaults to Jason but can be configured to Poison
  """
  @spec json_library() :: module
  def json_library do
    Config.resolve(:json_library, Jason)
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
    Config.resolve(:access_token)
  end

  @doc """
  In config.exs, use a string, a function or a tuple:
      config :ex_crowdin, project_id: System.get_env("CROWDIN_PROJECT_ID")

  or:
      config :ex_crowdin, access_token: {:system, "CROWDIN_PROJECT_ID"}

  or:
      config :ex_crowdin, access_token: {MyApp.Config, :crowdin_project_id, []}
  """
  def project_id do
    Config.resolve(:project_id)
  end

  defp api_path do
    @api_path
  end

  @spec add_default_headers(headers) :: headers
  defp add_default_headers(headers) do
    Map.merge(%{
      "Accept": "application/json; charset=utf8",
      "Content-Type": "application/json"
    },
      headers
    )
  end

  @spec add_auth_header(headers) :: headers
  defp add_auth_header(headers) do
    Map.put(headers, "Authorization", "Bearer #{access_token()}")
  end

  @spec request(String.t(), method, body, headers, list) ::
          {:ok, map} | {:error, Error.t()}
  def request(path, method, body \\ "", headers \\ %{}, opts \\ []) do
    req_url = build_path(path)

    req_headers =
      headers
      |> add_default_headers()
      |> add_auth_header()
      |> Map.to_list()

    encoded_body = encode_body(body, method, req_headers)

    @request_module.request(method, req_url, encoded_body, req_headers, opts)
  end

  defp encode_body(body, method, req_headers) do
    if method != :get && Keyword.get(req_headers, :"Content-Type") == "application/json" do
      json_library().encode!(body)
    else
      body
    end
  end

  defp build_path(path) do
    if String.starts_with?(path, "/") do
      "#{api_path()}#{path}"
    else
      "#{api_path()}/#{path}"
    end
  end

  @callback project_path(String.t(), String.t()) :: String.t()
  def project_path(project_id, path) do
    project_path = "/projects/#{project_id}"
    if String.starts_with?(path, "/") do
      "#{project_path}#{path}"
    else
      "#{project_path}/#{path}"
    end
  end
end
