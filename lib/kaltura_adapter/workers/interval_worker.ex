defmodule CtiKaltura.ProgramScheduling.IntervalWorker do
  @moduledoc """
  Содержит макрос, позволяющий созать GenServer, запускающий функцию &useful_job/0 c заданным интервалом.
  Кроме этого осуществляющий автоматическое логирование при запуске сервера.

  Использование:

  ```
  use CtiKaltura.ProgramScheduling.IntervalWorker,
        logging_domain: :worker_domain,
        configuration_alias: :worker_name

  ```

  :worker_domain - определяет домен логирования. В конфигурации должна быть определена:

  ```
  config :logger, :worker_domain_log,
    path: "log/worker_domain.log",
    metadata_filter: [domain: :worker_domain],
    level: :debug,
    format: "\n$date $time $metadata[$level] $message\n"
  ```

  :worker_name - в конфигурации должна быть прописана:

  ```
  config :cti_kaltura, :worker_name,
    # Если значение установлено в true - воркер запускает функцию useful_job с заданным интервалом, если false - нет.
    enabled: true,
    run_interval: 5000 # Интервал в милисекундах с которым будет запускаться useful_job
  ```

  После этого необходимо определить функцию:

  ```
  def useful_job do
    # Реализация полезной работы
    :ok
  end
  ```

  Для доступа к конфигурациям можно использовать функцию config().
  """

  defmacro __using__(options) do
    logging_gomain = Keyword.get(options, :logging_domain)
    configuration_alias = Keyword.get(options, :configuration_alias)

    quote do
      use GenServer
      use CtiKaltura.KalturaLogger, metadata: [domain: unquote(logging_gomain)]

      def start_link(_) do
        GenServer.start_link(__MODULE__, :ok, name: via_tuple(__MODULE__))
      end

      def init(:ok) do
        log_info("Starting with interval #{run_interval()}")
        schedule_periodical_job()
        {:ok, nil}
      end

      defp schedule_periodical_job do
        if enabled?() do
          Process.send_after(self(), :run_job, run_interval())
        end
      end

      def handle_info(:run_job, _state) do
        clean_program_records_time = NaiveDateTime.utc_now()

        useful_job()

        schedule_periodical_job()
        {:noreply, clean_program_records_time}
      end

      def useful_job do
        :ok
      end

      def terminate(reason, state) do
        log_error("Terminating server with reason: #{inspect(reason)}\nState: #{inspect(state)}")
      end

      defp via_tuple(name), do: {:global, name}

      # Configuration functions
      defp config, do: Application.get_env(:cti_kaltura, unquote(configuration_alias))

      defp run_interval, do: config()[:run_interval]

      defp enabled?, do: config()[:enabled]

      defoverridable useful_job: 0
    end
  end
end
