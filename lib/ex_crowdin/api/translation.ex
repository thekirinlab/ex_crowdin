defmodule ExCrowdin.Translation do
  @moduledoc """
  Work with Crowdin String translations

  Crowdin API reference: https://support.crowdin.com/api/v2/#tag/String-Translations
  """

  alias ExCrowdin.API

  def list(string_id, language_id, query \\ %{}, project_id \\ API.project_id()) do
    encoded_query =
      %{"stringId" => string_id, "languageId" => language_id}
      |> Map.merge(query)
      |> URI.encode_query()

    path = API.project_path(project_id, "/translations?#{encoded_query}")
    API.request(path, :get)
  end

  def add(body, project_id \\ API.project_id()) do
    path = API.project_path(project_id, "/translations")
    API.request(path, :post, body)
  end

  def delete(string_id, language_id, project_id \\ API.project_id()) do
    query = %{"stringId" => string_id, "languageId" => language_id} |> URI.encode_query()
    path = API.project_path(project_id, "/translations?#{query}")
    API.request(path, :delete)
  end
end
