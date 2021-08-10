defmodule ExCrowdin.Downloader do
  alias ExCrowdin.Translation

  def get_crowdin_translations(locale, field, file_id, page \\ 0) do
    record_per_page = 500

    with {:ok, %{"data" => data}} <-
           Translation.list_language_translations(
             locale,
             %{
               fileId: file_id,
               limit: record_per_page
             }
           ) do
      # if results return full item, there could be more results
      if length(data) == record_per_page do
        data = data ++ get_crowdin_translations(locale, field, file_id, page + 1)
        {:ok, data}
      else
        {:ok, data}
      end
    end
  end
end
