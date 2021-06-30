defmodule ExCrowdin.String do
  @moduledoc """
  Work with Crowdin source strings

  Crowdin API reference: https://support.crowdin.com/api/v2/#tag/Source-Strings
  """

  alias ExCrowdin.API

  def list do
    API.request("/strings", :get)
  end
end
