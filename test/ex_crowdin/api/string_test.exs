defmodule ExCrowdin.StringTest do
  use ExUnit.Case

  alias ExCrowdin.{File, Storage, String}
  alias ExCrowdin.RequestMock

  import Mox
  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  test "GET /project/:project_id/strings" do
    sample_response =
      {:ok,
       %{
         "data" => [
           %{
             "data" => %{
               "branchId" => nil,
               "context" =>
                 "This text has no context info. The text is used in errors.pot. Position in file: 1",
               "createdAt" => "2021-06-29T04:21:42+00:00",
               "fileId" => 2,
               "hasPlurals" => false,
               "id" => 2,
               "identifier" => "can't be blank",
               "isHidden" => false,
               "isIcu" => false,
               "labelIds" => [],
               "maxLength" => 0,
               "projectId" => 462_944,
               "revision" => 1,
               "text" => "can't be blank",
               "type" => "text",
               "updatedAt" => nil
             }
           }
         ]
       }}

    RequestMock
    |> expect(:request, fn _, _, _, _, _ ->
      sample_response
    end)

    assert {:ok, response} = String.list()
    assert response["data"]
  end

  test "POST /project/:project_id/strings" do
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
      "type" => "macosx"
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

    # ADD STRING
    file_id = file_response["data"]["id"]

    body = %{
      text: "Not all videos are shown to users. See more",
      identifier: "test_123",
      fileId: file_id,
      context: "shown on main page",
      isHidden: false,
      maxLength: 35
    }

    RequestMock
    |> expect(:request, fn _, _, _, _, _ ->
      {:ok,
       %{
         "data" => %{
           "branchId" => nil,
           "context" => "test_123\nshown on main page",
           "createdAt" => "2021-07-01T07:46:10+00:00",
           "fileId" => 20,
           "hasPlurals" => false,
           "id" => 1532,
           "identifier" => "test_123",
           "isHidden" => false,
           "isIcu" => false,
           "labelIds" => [],
           "maxLength" => 35,
           "projectId" => 462_944,
           "revision" => 2,
           "text" => "Not all videos are shown to users. See more",
           "type" => "text",
           "updatedAt" => nil
         }
       }}
    end)

    assert {:ok, _} = String.add(body)
  end

  test "DELETE /project/:project_id/strings" do
    id = 1538

    RequestMock
    |> expect(:request, fn _, _, _, _, _ ->
      {:ok, ""}
    end)

    assert {:ok, ""} = String.delete(id)
  end
end
