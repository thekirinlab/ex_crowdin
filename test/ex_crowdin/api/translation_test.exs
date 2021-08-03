defmodule ExCrowdin.TranslationTest do
  use ExUnit.Case

  alias ExCrowdin.{String, Translation}
  alias ExCrowdin.RequestMock

  import Mox
  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  test "GET /project/:project_id/strings" do
    string_id = 1540
    RequestMock
    |> expect(:request, fn _, _, _, _, _ ->
      {:ok,
        %{
          "data" => [
            %{
              "data" => %{
                "createdAt" => "2021-07-01T09:06:24+00:00",
                "id" => 5406,
                "pluralCategoryName" => nil,
                "rating" => 0,
                "text" => "Tidak semua video ditampilkan",
                "user" => %{
                  "avatarUrl" => "https://www.gravatar.com/avatar/4160fc3f5549356e5401e4e58b4e8fa0?s=48&d=https%3A%2F%2Fcrowdin.com%2Fimages%2Fuser-picture.png",
                  "fullName" => "tantf",
                  "id" => 14819640,
                  "username" => "tantf"
                }
              }
            }
          ],
          "pagination" => %{"limit" => 25, "offset" => 0}
        }}
    end)

    assert {:ok, _} = Translation.list(string_id, "id")
  end


  test "POST /project/:project_id/strings" do
    # ADD STRING
    file_id = 24

    body = %{
      "text": "Not all videos are shown to users. See more",
      "identifier": "test_123",
      "fileId": file_id,
      "context": "shown on main page",
      "isHidden": false,
      "maxLength": 35
    }

    RequestMock
    |> expect(:request, fn _, _, _, _, _ ->
      {:ok,
        %{
          "data" => %{
            "branchId" => nil,
            "context" => "test_123\nshown on main page",
            "createdAt" => "2021-07-01T08:31:02+00:00",
            "fileId" => 24,
            "hasPlurals" => false,
            "id" => 1540,
            "identifier" => "test_123",
            "isHidden" => false,
            "isIcu" => false,
            "labelIds" => [],
            "maxLength" => 35,
            "projectId" => 462944,
            "revision" => 6,
            "text" => "Not all videos are shown to users. See more",
            "type" => "text",
            "updatedAt" => nil
          }
        }}
    end)

    {:ok, response} = String.add(body)

    string_id = response["data"]["id"]
    translation_body = %{
      "stringId": string_id,
      "languageId": "id",
      "text": "Tidak semua video ditampilkan."
    }

    RequestMock
    |> expect(:request, fn _, _, _, _, _ ->
      {:ok,
        %{
          "data" => %{
            "createdAt" => "2021-07-01T09:34:11+00:00",
            "id" => 5408,
            "pluralCategoryName" => nil,
            "rating" => 0,
            "text" => "Tidak semua video ditampilkan.",
            "user" => %{
              "avatarUrl" => "https://www.gravatar.com/avatar/4160fc3f5549356e5401e4e58b4e8fa0?s=48&d=https%3A%2F%2Fcrowdin.com%2Fimages%2Fuser-picture.png",
              "fullName" => "tantf",
              "id" => 14819640,
              "username" => "tantf"
            }
          }
        }}
    end)

    assert {:ok, _} = Translation.add(translation_body)
  end

  test "DELETE /project/:project_id/strings" do
    string_id = 1540
    RequestMock
    |> expect(:request, fn _, _, _, _, _ ->
      {:ok, ""}
    end)

    assert {:ok, ""} = Translation.delete(string_id, "id")
  end
end
