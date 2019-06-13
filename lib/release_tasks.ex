defmodule CtiKaltura.ReleaseTasks do
  @moduledoc """
  Содержит функции, которые должны выполняться после запуска системы.
  1. Прогон миграций
  2. Создание схемы для Mnesia
  3. Перенос БД в Mnesia
  """

  use CtiKaltura.KalturaLogger, metadata: [domain: :release_tasks]

  alias CtiKaltura.{NodesService, Seed}
  alias Ecto.Migrator

  @otp_app :cti_kaltura
  @kaltura_admin_public_api Application.get_env(:cti_kaltura, :public_api)[:module]
  @prod_env_regex ~r/prod/

  @doc """
  Perform migrations.
  """
  def migrate_repo do
    puts_message("Run migrations")
    run_in_not_test_env(fn -> run_migrations_for(@otp_app) end)
  end

  @doc """
  Cache all necessary records to provide api request processing.
  """
  def cache_domain_model do
    puts_message("Cache domain model")
    run_in_not_test_env(fn -> @kaltura_admin_public_api.cache_domain_model_at_server() end)
  end

  @doc """
  Fill in database with seed data. ! USE CAREFULLY ! Don't use in production.
  """
  def seed do
    puts_message("Seed database")

    if is_nil(Regex.run(@prod_env_regex, current_env())) do
      Seed.perform()
    end
  end

  defp run_migrations_for(app) do
    puts_message("Running migrations for #{app}")

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
    log_info(message)
    run_in_not_test_env(fn -> IO.puts("# #{message}") end)
  end

  defp puts_error_message(message) do
    log_error(message)
    run_in_not_test_env(fn -> IO.puts("# #{message}") end)
  end

  defp run_in_not_test_env(fun) do
    if Application.get_env(:cti_kaltura, :env)[:current] != :test do
      fun.()
    end
  end

  @doc """
  Perform manipulations to achieve mnesia clustering
  """
  def make_mnesia_cluster_again do
    puts_message("Make mnesia cluster again")
    nodes = NodesService.get_nodes()

    if length(nodes) > 1 do
      puts_message("Stopping mnesia")

      run_on_each_node(nodes, fn ->
        :mnesia.stop()
        file_path = "#{File.cwd!()}/Mnesia.#{Node.self()}"
        System.cmd("rm", ["-rf", file_path])
      end)

      puts_message("Creating schema")

      case Amnesia.Schema.create(nodes) do
        :ok ->
          puts_message("Starting mnesia again")

          run_on_each_node(nodes, fn ->
            :mnesia.start()
          end)

          :timer.sleep(500)

          puts_message("Initializing DomainModel")
          DomainModel.create(memory: nodes)
          DomainModel.add_indexes()

          cache_domain_model()

        error ->
          puts_error_message("Error during resetting mnesia: #{inspect(error)}")
      end
    else
      puts_message("Error during making clusters. Not all clusters are running")
    end
  end

  defp current_env do
    Application.get_env(:cti_kaltura, :env)[:current]
  end

  defp run_on_each_node(nodes, fun) do
    nodes
    |> Enum.each(fn node ->
      Node.spawn(node, fun)
    end)
  end

  @doc """
  Reset mnesia database if it's run on single node.
  """
  def reset_single_mnesia do
    puts_message("Reset single mnesia")
    nodes = NodesService.get_nodes()

    if length(nodes) > 1 do
      puts_message("Can't reset mnesia. There is cluster")
    else
      puts_message("Stopping mnesia")
      :mnesia.stop()
      file_path = "#{File.cwd!()}/Mnesia.#{Node.self()}"
      System.cmd("rm", ["-rf", file_path])

      puts_message("Creating schema")

      case Amnesia.Schema.create() do
        :ok ->
          puts_message("Starting mnesia again")
          :mnesia.start()
          :timer.sleep(500)

          puts_message("Initializing DomainModel")
          DomainModel.create(memory: [Node.self()])
          DomainModel.add_indexes()

          cache_domain_model()

        error ->
          puts_error_message("Error during resetting mnesia: #{inspect(error)}")
      end
    end
  end
end
