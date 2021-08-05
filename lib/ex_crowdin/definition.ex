defmodule ExCrowdin.Definition do
  @moduledoc """
  Upload provider profile's copy to Crowdin and download translations from Crowdin
  """

  @default_string_ids_field  :crowdin_string_ids

  defmacro __using__(opts) do
    quote do
      Module.put_attribute(__MODULE__, :ex_crowdin_fields, unquote(synchronizable_fields(opts)))
      Module.put_attribute(__MODULE__, :ex_crowdin_name, unquote(synchronizable_name(opts, __CALLER__.module)))
      Module.put_attribute(__MODULE__, :ex_crowdin_string_ids_field, unquote(synchronizable_string_ids_field(opts)))

      @spec __synchronize__(:fields) :: list(atom)
      def __synchronize__(:fields), do: @ex_crowdin_fields

      @spec __synchronize__(:name) :: binary
      def __synchronize__(:name), do: @ex_crowdin_name

      @spec __synchronize__(:name) :: atom
      def __synchronize__(:string_ids_field), do: @ex_crowdin_string_ids_field
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

  defp synchronizable_name(opts, caller_module) do
    case Keyword.fetch(opts, :name) do
      :error -> name_from_module(caller_module)
      {:ok, name} -> name
    end
  end

  defp synchronizable_string_ids_field(opts) do
    case Keyword.fetch(opts, :string_ids_field) do
      {:ok, string_ids_field} when is_atom(string_ids_field) ->
        string_ids_field

      _ -> @default_string_ids_field
    end
  end

  defp name_from_module(caller_module) do
    caller_module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
  end
end
