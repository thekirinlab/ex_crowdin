defmodule ExCrowdin.Sync.Uploader do
  import ExCrowdin.QueryBuider, only: [synchronized: 3]
  import Ecto.Query, only: [from: 2]

  require Logger

  def run(repo, ex_crowdin_schema, query, sync_module) do
    string_ids_field = ex_crowdin_schema.__synchronize__(:string_ids_field)

    ex_crowdin_schema.__synchronize__(:fields)
    |> Enum.map(fn field ->
      with {:ok, file_id} <- ExCrowdin.get_file_id(%{__struct__: ex_crowdin_schema}, field) do
        load_records_to_be_uploaded(repo, query, field, string_ids_field, sync_module)
        |> Enum.map(fn record ->
          upload_one(repo, record, field, file_id, string_ids_field)
        end)
      end
    end)
  end

  defp upload_one(repo, record, field, file_id, string_ids_field) do
    with {:ok, string_id} <- ExCrowdin.upload_one(record, field, file_id) do
      crowdin_string_ids =
        Map.get(record, string_ids_field)
        |> Kernel.||(%{})
        |> Map.merge(%{"#{field}" => string_id})

      Ecto.Changeset.change(record, %{"#{string_ids_field}": crowdin_string_ids})
      |> repo.update()
    end
  end

  defp load_records_to_be_uploaded(repo, query, field, string_ids_field, sync_module) do
    Logger.debug("query: #{inspect(query)}")

    from(
      q in query,
      where: is_nil(synchronized(q, ^string_ids_field, field)),
      where: not is_nil(field(q, ^field))
    )
    |> repo.all()
    |> Enum.map(fn record ->
      value = Map.get(record, field)
      serialized_value = sync_module.serialize_field(field, value)
      Map.merge(record, %{:"#{field}" => serialized_value})
    end)
  end
end
