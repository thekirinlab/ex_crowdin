defmodule ExCrowdin.StorageTest do
  use ExUnit.Case

  alias ExCrowdin.Storage
  alias ExCrowdin.RequestMock

  import Mox
  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  test "GET /storages" do
  end

  test "POST /storage" do
    body = " "
    filename = "test_file_124.strings"

    RequestMock
    |> expect(:request, fn _, _, _, _, _ ->
      {:ok, %{"data" => %{"fileName" => "test_file_124.strings", "id" => 620_306_914}}}
    end)

    {:ok, storage_response} = Storage.add(body, filename)
    assert storage_response["data"]["id"]
  end
end
