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
    Map.put(headers, "Authorization", "Bearer #{Config.access_token()}")
  end

  @spec request(String.t(), method, body, headers, list) ::
          {:ok, map} | {:error, any()}
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
      Config.json_library().encode!(body)
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
