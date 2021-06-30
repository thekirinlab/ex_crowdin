defmodule ExCrowdin.API do
  @moduledoc """
  Utilities for interacting with the Crowdin API v2.
  """

  alias ExCrowdin.Config
  alias HTTPoison.{Error, Response}
  require Logger

  @type method :: :get | :post | :put | :delete | :patch
  @type headers :: %{String.t() => String.t()} | %{}
  @type body :: iodata() | {:multipart, list()}

  @doc """
  In config.exs your implicit or expicit configuration is:
    config ex_:crowdin,
      json_library: Poison # defaults to Jason but can be configured to Poison
  """
  @spec json_library() :: module
  def json_library do
    Config.resolve(:json_library, Jason)
  end

  @doc """
  In config.exs:
    config :ex_crowdin,
      access_token: "<your personal access token on Crowdin>"
  """
  def access_token do
    Config.resolve(:access_token)
  end

  @doc """
  In config.exs:
    config :ex_crowdin,
      project_id: "<your project ID on Crowdin>"
  """
  def project_id do
    Config.resolve(:project_id)
  end

  def domain do
    "https://api.crowdin.com/api/v2/projects/#{project_id()}"
  end

  @spec add_default_headers(headers) :: headers
  def add_default_headers(headers) do
    Map.merge(headers, %{
      "Accept" => "application/json; charset=utf8",
      "Content-Type" => "application/json"
      # "Accept-Encoding" => "gzip",
      # "Connection" => "keep-alive"
    })
    |> IO.inspect()
  end

  @spec add_auth_header(headers) :: headers
  defp add_auth_header(headers) do
    Map.put(headers, "Authorization", "Bearer #{access_token()}")
  end

  @spec request(String.t(), method, body, headers, list) ::
          {:ok, map} | {:error, Stripe.Error.t()}
  def request(path, method, body \\ "", headers \\ %{}, opts \\ []) do
    req_url = build_path(path)

    req_headers =
      headers
      |> add_default_headers()
      |> add_auth_header()
      |> Map.to_list()

    HTTPoison.request(method, req_url, body, req_headers, opts)
    |> IO.inspect()
    |> handle_response()
  end

  defp handle_response({:ok, %Response{body: body, status_code: code}})
       when code in 200..299 do
    {:ok, json_library().decode!(body)}
  end

  defp handle_response(
         {:ok, %Response{body: body, status_code: _, request_url: request_url}}
       ) do
    Logger.error(inspect(body))
    Logger.error(inspect(request_url))
    {:error, body}
  end

  defp handle_response({:error, %Error{} = error}),
    do: {:error, error}

  defp build_path(path) do
    if String.starts_with?(path, "/") do
      "#{domain()}#{path}"
    else
      "#{domain()}/#{path}"
    end
  end
end
