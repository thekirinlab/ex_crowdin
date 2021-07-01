defmodule ExCrowdin.String do
  @moduledoc """
  Work with Crowdin source strings

  Crowdin API reference: https://support.crowdin.com/api/v2/#tag/Source-Strings
  """

  alias ExCrowdin.API

  def list(project_id \\ API.project_id()) do
    path = API.project_path(project_id, "/strings")
    API.request(path, :get)
  end

  def add(body, project_id \\ API.project_id()) do
    path = API.project_path(project_id, "/strings")
    API.request(path, :post, body)
  end

  def delete(string_id, project_id \\ API.project_id()) do
    path = API.project_path(project_id, "/strings/#{string_id}")
    API.request(path, :delete)
  end
end
