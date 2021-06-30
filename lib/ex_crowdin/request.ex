defmodule ExCrowdin.Request do
  @moduledoc """
  Utilities to send request to Crowdin API v2
  """

  alias HTTPoison.{Error, Response}
  require Logger

  alias ExCrowdin.API

  @callback request(String.t(), String.t(), any(), list, list) :: {:ok, map} | {:error, any()}
  def request(method, req_url, body, req_headers, opts) do
    Logger.debug(req_url)
    HTTPoison.request(method, req_url, body, req_headers, opts)
    |> handle_response()
  end

  defp handle_response({:ok, %Response{body: body, status_code: code}})
       when code in 200..299 do
    {:ok, API.json_library().decode!(body)}
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
end
