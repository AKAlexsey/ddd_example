defmodule CtiKaltura.KalturaLogger do
  @moduledoc """
  Добавляет в модуль функции для логирования.
  Позволяет задавать metadata при инициализации. Чтобы все сообщения из модуля, попадали в определённый Backend
  """

  defmacro __using__(opts) do
    default_metadata = Keyword.get(opts, :metadata, [])

    quote do
      require Logger

      @logger_module_name __MODULE__

      defdelegate log_metadata(meta), to: Logger, as: :metadata
      defdelegate log_configure(config), to: Logger, as: :configure
      defdelegate log_add_backend(backend, opts \\ []), to: Logger, as: :add_backend
      defdelegate log_remove_backend(backend, opts \\ []), to: Logger, as: :remove_backend
      defdelegate log_configure_backend(backend, opts \\ []), to: Logger, as: :configure_backend

      @spec log_debug(binary) :: :ok
      def log_debug(string, metadata \\ []) do
        Logger.debug(
          fn -> logger_module_message(string) end,
          Keyword.merge(unquote(default_metadata), metadata)
        )
      end

      @spec log_info(binary) :: :ok
      def log_info(string, metadata \\ []) do
        Logger.info(
          fn -> logger_module_message(string) end,
          Keyword.merge(unquote(default_metadata), metadata)
        )
      end

      @spec log_warn(binary) :: :ok
      def log_warn(string, metadata \\ []) do
        Logger.warn(
          fn -> logger_module_message(string) end,
          Keyword.merge(unquote(default_metadata), metadata)
        )
      end

      @spec log_error(binary) :: :ok
      def log_error(string, metadata \\ []) do
        Logger.error(
          fn -> logger_module_message(string) end,
          Keyword.merge(unquote(default_metadata), metadata)
        )
      end

      defp logger_module_message(string), do: "[#{@logger_module_name}] #{string}"
    end
  end
end
