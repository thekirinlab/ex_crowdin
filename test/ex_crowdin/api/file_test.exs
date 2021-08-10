defmodule ExCrowdin.FileTest do
  use ExUnit.Case

  alias ExCrowdin.{File, Storage}
  alias ExCrowdin.RequestMock

  import Mox
  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  test "GET /project/:project_id/files" do
  end

  test "POST /project/:project_id/files" do
    # ADD STORAGE
    body = " "
    filename = "test_file_124.strings"

    RequestMock
    |> expect(:request, fn _, _, _, _, _ ->
      {:ok, %{"data" => %{"fileName" => "test_file_124.strings", "id" => 620_306_914}}}
    end)

    {:ok, storage_response} = Storage.add(body, filename)
    storage_id = storage_response["data"]["id"]

    # ADD FILE
    file_body = %{
      "storageId" => storage_id,
      "name" => filename,
      "title" => "test_file",
      "type" => "json"
    }

    RequestMock
    |> expect(:request, fn _, _, _, _, _ ->
      {:ok,
       %{
         "data" => %{
           "branchId" => nil,
           "createdAt" => "2021-07-01T07:45:46+00:00",
           "directoryId" => nil,
           "excludedTargetLanguages" => nil,
           "exportOptions" => nil,
           "id" => 20,
           "importOptions" => nil,
           "name" => "test_file_124.strings",
           "path" => "/test_file_124.strings",
           "priority" => "normal",
           "projectId" => 462_944,
           "revisionId" => 1,
           "status" => "active",
           "title" => "test_file",
           "type" => "macosx",
           "updatedAt" => "2021-07-01T07:45:47+00:00"
         }
       }}
    end)

    {:ok, file_response} = File.add(file_body)

    assert file_response
    assert file_response["data"]["id"]
  end
end
