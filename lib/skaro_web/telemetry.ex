defmodule SkaroWeb.Telemetry do
  use Supervisor

  import Telemetry.Metrics

  require Logger

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children =
      [
        # Telemetry poller will execute the given period measurements
        # every Nms. Learn more here: https://hexdocs.pm/telemetry_metrics
        {:telemetry_poller, measurements: periodic_measurements(), period: 30_000}
      ] ++ reporters()

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Database Metrics
      distribution("skaro.repo.query.total_time",
        tags: [:env, :service],
        unit: {:native, :millisecond},
        description: "The sum of the other measurements"
      ),
      distribution("skaro.repo.query.decode_time",
        tags: [:env, :service],
        unit: {:native, :millisecond},
        description: "The time spent decoding the data received from the database"
      ),
      distribution("skaro.repo.query.query_time",
        tags: [:env, :service],
        unit: {:native, :millisecond},
        description: "The time spent executing the query"
      ),
      distribution("skaro.repo.query.queue_time",
        tags: [:env, :service],
        unit: {:native, :millisecond},
        description: "The time spent waiting for a database connection"
      ),
      distribution("skaro.repo.query.idle_time",
        tags: [:env, :service],
        unit: {:native, :millisecond},
        description:
          "The time the connection spent waiting before being checked out for the query"
      ),

      # VM Metrics
      summary("vm.memory.total",
        tags: [:env, :service],
        unit: {:byte, :kilobyte}
      ),
      summary("vm.total_run_queue_lengths.total", tags: [:env, :service]),
      summary("vm.total_run_queue_lengths.cpu", tags: [:env, :service]),
      summary("vm.total_run_queue_lengths.io", tags: [:env, :service])
    ]
  end

  defp periodic_measurements do
    []
  end

  defp reporters do
    if Application.fetch_env!(:skaro, __MODULE__)[:report_metrics] do
      [
        {TelemetryMetricsStatsd,
         metrics: metrics(),
         global_tags: [env: "fly", service: "igroteka"],
         host: "ddagent.internal",
         inet_address_family: :inet6,
         formatter: :datadog}
      ]
    else
      []
    end
  end
end
