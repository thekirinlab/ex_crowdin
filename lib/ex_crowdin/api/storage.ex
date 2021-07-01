defmodule ExCrowdin.Storage do
  @moduledoc """
  Work with Crowdin source strings

  Crowdin API reference: https://support.crowdin.com/api/v2/#tag/Source-Strings
  """

  alias ExCrowdin.API

  def list do
    API.request("/storages", :get)
  end

  def add(body, filename) do
    API.request(
      "/storages",
      :post,
      body,
      %{
        "Crowdin-API-FileName" => filename,
        "Content-Type" => "application/octet-stream"
      })
  end
end
