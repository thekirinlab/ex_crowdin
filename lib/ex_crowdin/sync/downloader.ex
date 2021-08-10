defmodule ExCrowdin.Sync.Downloader do
  import ExCrowdin.QueryBuider, only: [synchronized: 3]
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset, only: [change: 2]

  @doc """
  Download copy from Crowdin and update schema's translations field
  """
  def run(repo, schema, query, locales, sync_module) do
    schema.__synchronize__(:fields)
    |> Enum.map(fn field ->
      download_field(repo, schema, query, field, locales, sync_module)
    end)
  end

  defp download_field(repo, schema, query, field, locales, sync_module) do
    string_ids_field = schema.__synchronize__(:string_ids_field)

    with {:ok, file_id} <- ExCrowdin.get_file_id(%{__struct__: schema}, field) do
      Enum.each(locales, fn locale ->
        with {:ok, data} <- ExCrowdin.get_crowdin_translations(locale, field, file_id) do
          Enum.each(data, fn response ->
            update_translations(repo, query, field, string_ids_field, response, sync_module)
          end)
        end
      end)
    end
  end

  defp update_translations(repo, query, field, string_ids_field, response, sync_module) do
    if response["data"] do
      string_id = response["data"]["stringId"]
      record = find_record_by_string_id(string_id, repo, query, field, string_ids_field)

      if record do
        text = sync_module.deserialize_field(field, response["data"]["text"])
        translations = record.translations |> Map.merge(%{"#{field}": text})

        change(record, %{translations: translations})
        |> repo.update()
      end
    end
  end

  defp find_record_by_string_id(nil, _, _, _, _), do: nil

  defp find_record_by_string_id(string_id, repo, query, field, string_ids_field) do
    from(
      q in query,
      where: synchronized(q, ^string_ids_field, field) == ^"#{string_id}",
      limit: 1
    )
    |> repo.one()
  end
end
