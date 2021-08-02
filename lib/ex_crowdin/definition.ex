defmodule ExCrowdin.Definition do
  @moduledoc """
  Upload provider profile's copy to Crowdin and download translations from Crowdin
  """

  defmacro __using__(opts) do
    quote do
      Module.put_attribute(__MODULE__, :ex_crowdin_fields, unquote(synchronizable_fields(opts)))
      Module.put_attribute(__MODULE__, :ex_crowdin_name, unquote(synchronizable_name(opts)))

      @spec __synchronize__(:fields) :: list(atom)
      def __synchronize__(:fields), do: @ex_crowdin_fields

      @spec __synchronize__(:name) :: binary
      def __synchronize__(:name), do: @ex_crowdin_name
    end
  end

  defp synchronizable_fields(opts) do
    case Keyword.fetch(opts, :fields) do
      {:ok, fields} when is_list(fields) ->
        fields

      _ ->
        raise ArgumentError,
          message:
            "ExCrowdinSync requires a 'fields' option that contains the list of fields names to be sync with Crowdin"
    end
  end

  defp synchronizable_name(opts) do
    case Keyword.fetch(opts, :name) do
      :error -> name_from_module()
      {:ok, name} -> name
    end
  end

  defp name_from_module do
    __MODULE__
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
  end
end
