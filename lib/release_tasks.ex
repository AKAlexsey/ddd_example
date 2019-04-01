defmodule CtiKaltura.ReleaseTasks do
  @moduledoc """
  Содержит функции, которые должны выполняться после запуска системы.
  1. Прогон миграций
  2. Создание схемы для Mnesia
  3. Перенос БД в Mnesia
  """
  alias Ecto.Migrator
  alias CtiKaltura.Seed

  @otp_app :cti_kaltura
  @kaltura_admin_public_api Application.get_env(:cti_kaltura, :public_api)[:module]

  def migrate_repo do
    puts_message("# ReleaseTasks run_migrations")
    run_in_not_test_env(fn -> run_migrations_for(@otp_app) end)
  end

  def create_mnesia_schema do
    puts_message("# ReleaseTasks create_mnesia_schema")
    create_schema()
    initialize_tables()
  end

  def cache_domain_model do
    puts_message("# ReleaseTasks cache_domain_model")
    run_in_not_test_env(fn -> @kaltura_admin_public_api.cache_domain_model_at_server() end)
  end

  defp create_schema do
    :mnesia.stop()
    Amnesia.Schema.create()
  end

  defp initialize_tables do
    :mnesia.start()
    DomainModel.create(memory: [Node.self()])
    DomainModel.add_indexes()
  end

  def seed do
    Seed.perform()
  end

  defp run_migrations_for(app) do
    puts_message("# Running migrations for #{app}")

    app
    |> Application.get_env(:ecto_repos, [])
    |> Enum.each(&Migrator.run(&1, migrations_path(app), :up, all: true))
  end

  defp migrations_path(app), do: priv_dir(app, ["repo", "migrations"])

  defp priv_dir(app, path) when is_list(path) do
    case :code.priv_dir(app) do
      priv_path when is_list(priv_path) or is_binary(priv_path) ->
        Path.join([priv_path] ++ path)

      {:error, :bad_name} ->
        raise ArgumentError, "unknown application: #{inspect(app)}"
    end
  end

  defp puts_message(message) do
    run_in_not_test_env(fn -> IO.puts(message) end)
  end

  defp run_in_not_test_env(fun) do
    if Application.get_env(:cti_kaltura, :env)[:current] != :test do
      fun.()
    end
  end
end
