defmodule ExCrowdin.Synchronizable do
  alias ExCrowdin.Sync.{Downloader, Uploader}

  defmacro __using__(opts) do
    if opts[:schema] && opts[:repo] && opts[:locales] do
      quote bind_quoted: [opts: opts] do
        @behaviour ExCrowdin.Synchronizable

        Module.put_attribute(__MODULE__, :ex_crowdin_schema, opts[:schema])
        Module.put_attribute(__MODULE__, :ex_crowdin_repo, opts[:repo])
        Module.put_attribute(__MODULE__, :ex_crowdin_locales, opts[:locales])

        @spec upload() :: any()
        def upload do
          query = synchronizable_query()
          Uploader.run(@ex_crowdin_repo, @ex_crowdin_schema, query, __MODULE__)
        end

        @spec download() :: any()
        def download do
          query = synchronizable_query()

          Downloader.run(
            @ex_crowdin_repo,
            @ex_crowdin_schema,
            query,
            @ex_crowdin_locales,
            __MODULE__
          )
        end

        @doc """
        Return all schema records by default, override this function to reduce query scope
        """
        @spec synchronizable_query() :: Ecto.Queryable
        def synchronizable_query do
          @ex_crowdin_schema
        end

        @doc """
        Override if values need to be serialized
        """
        @spec serialize_field(atom(), any()) :: binary()
        def serialize_field(_, value), do: value

        @spec deserialize_field(atom(), binary()) :: any()
        def deserialize_field(_, value), do: value

        defoverridable upload: 0,
                       download: 0,
                       synchronizable_query: 0,
                       serialize_field: 2,
                       deserialize_field: 2
      end
    else
      raise ArgumentError,
        message: "ExCrowdin.Synchronizable requires schema, repo and locales option"
    end
  end

  @callback upload() :: any()
  @callback download() :: any()
  @callback synchronizable_query() :: Ecto.Queryable

  @callback serialize_field(atom(), any()) :: binary()
  @callback deserialize_field(atom(), binary()) :: any()
end
