defmodule ExCrowdin.File do
  @moduledoc """
  Work with Crowdin source strings

  Crowdin API reference: https://support.crowdin.com/api/v2/#tag/Source-Strings
  """

  alias ExCrowdin.API

  def list(project_id \\ API.project_id()) do
    path = API.project_path(project_id, "/files")
    API.request(path, :get)
  end

  def add(body, project_id \\ API.project_id()) do
    path = API.project_path(project_id, "/files")
    API.request(path, :post, body)
  end
end
