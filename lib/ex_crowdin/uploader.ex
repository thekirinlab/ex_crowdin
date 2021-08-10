defmodule ExCrowdin.Uploader do
  require Logger

  alias ExCrowdin.File, as: ExCrowdinFile
  alias ExCrowdin.String, as: ExCrowdinString
  alias ExCrowdin.Storage, as: ExCrowdinStorage

  def get_filename(struct, field) do
    "#{get_title(struct, field)}.strings"
  end

  def get_title(%{__struct__: module}, field) do
    "#{module.__synchronize__(:name)}_#{field}"
  end

  def upload_one(struct, field, file_id) do
    string_body = build_string_body(struct, field, file_id)

    with {:ok, response} <- ExCrowdinString.add(string_body) do
      Logger.info("Uploaded #{field} #{struct.id} to Crowdin")
      string_id = response["data"]["id"]

      {:ok, string_id}
    else
      {:error, error} ->
        if String.contains?(error, "identifier") && String.contains?(error, "notUnique") do
          # response to Crowdin sometime times out but string was still added
          retrieve_string_id_from_crowdin(struct, field)
        else
          Logger.error("Error uploading #{field} to Crowdin: #{inspect(error)}")
          {:error, error}
        end
    end
  end

  defp retrieve_string_id_from_crowdin(struct, field) do
    identfier = get_identifier(struct, field)

    with {:ok, response} <- ExCrowdinString.list(%{"filter" => identfier}) do
      item_response = is_list(response["data"]) && List.first(response["data"])

      if item_response && item_response["data"] do
        string_id = item_response["data"]["id"]

        {:ok, string_id}
      else
        {:error, :not_found}
      end
    end
  end

  defp get_identifier(struct, field) do
    title = get_title(struct, field)
    "#{title}_#{struct.id}"
  end

  defp build_string_body(struct, field, file_id) do
    %{
      text: build_text(struct, field),
      identifier: get_identifier(struct, field),
      fileId: file_id,
      context: get_title(struct, field),
      isHidden: false
    }
  end

  defp build_text(struct, field) do
    Map.get(struct, field)
  end

  # Uploading strings require us to create a file in Crowdin first
  # Tfw.Utils.CrowdinUpload.create_crowdin_file(%Pack{})
  def create_crowdin_file(%{__struct__: module} = struct) do
    module.__synchronize__(:fields)
    |> Enum.map(fn field ->
      create_crowdin_file(struct, field)
    end)
  end

  def create_crowdin_file(struct, field) do
    filename = get_filename(struct, field)

    with {:ok, storage_response} <- ExCrowdinStorage.add(" ", filename),
         file_body <- build_file_body(struct, storage_response["data"]["id"], field),
         {:ok, file_response} <- ExCrowdinFile.add(file_body) do
      file_id = file_response["data"]["id"]
      Logger.info("Init file successfully with file ID #{file_id}")
      Logger.info(inspect(file_response))
      {:ok, file_response}
    else
      {:error, error} ->
        Logger.error("Error creating file on Crowdin: #{inspect(error)}")
        {:error, error}
    end
  end

  @spec get_file_id(struct(), atom()) :: {:ok, binary()} | {:error, any()}
  def get_file_id(struct, field) do
    filename = get_filename(struct, field)

    with {:ok, response} <- ExCrowdinFile.list(%{"filter" => filename}) do
      item_response = List.first(response["data"])

      if item_response && item_response["data"] do
        {:ok, item_response["data"]["id"]}
      else
        with {:ok, file_response} <- create_crowdin_file(struct, field) do
          {:ok, file_response["data"]["id"]}
        end
      end
    end
  end

  defp build_file_body(struct, storage_id, field) do
    %{
      "storageId" => storage_id,
      "name" => get_filename(struct, field),
      "title" => get_title(struct, field),
      "type" => "macosx"
    }
  end
end
