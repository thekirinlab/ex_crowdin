if Code.ensure_loaded?(Ecto.Adapters.SQL) do
  defmodule ExCrowdin.QueryBuider do
    # synchronized(p, :crowdin_string_ids, field)
    defmacro synchronized(synchronizable, crowdin_string_field, field) do
      # TODO: validate fields in complation time
      # module = Macro.expand(module, __CALLER__)
      # validate_field(module, field)
      generate_query(schema(synchronizable), crowdin_string_field, field)
    end

    defp generate_query(schema, crowdin_string_field, field) do
      quote do
        fragment(
          "(?->>?)",
          field(unquote(schema), unquote(crowdin_string_field)),
          ^to_string(unquote(field))
        )
      end
    end

    defp schema({{:., _, [schema, _field]}, _metadata, _args}), do: schema
    defp schema(schema), do: schema
  end
end
