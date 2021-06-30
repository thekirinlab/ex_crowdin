defmodule ExCrowdin.StringTest do
  use ExUnit.Case

  alias ExCrowdin.String
  alias ExCrowdin.RequestMock

  import Mox
  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!


  test "GET /project/:project_id/strings" do
    sample_response = {:ok,
      %{
        "data" => [
          %{
            "data" => %{
              "branchId" => nil,
              "context" => "This text has no context info. The text is used in errors.pot. Position in file: 1",
              "createdAt" => "2021-06-29T04:21:42+00:00",
              "fileId" => 2,
              "hasPlurals" => false,
              "id" => 2,
              "identifier" => "can't be blank",
              "isHidden" => false,
              "isIcu" => false,
              "labelIds" => [],
              "maxLength" => 0,
              "projectId" => 462944,
              "revision" => 1,
              "text" => "can't be blank",
              "type" => "text",
              "updatedAt" => nil
            }
          }
          ]
        }
      }

    RequestMock
    |> expect(:request, fn _, _, _, _, _ ->
      sample_response
    end)

    assert {:ok, response} = String.list() |> IO.inspect()
    assert response["data"]
  end

  test "list the strings" do

  end
end
