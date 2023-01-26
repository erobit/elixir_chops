defmodule Store.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    :ok = Logger.add_translator({Timber.Exceptions.Translator, :translate})

    :ok =
      :telemetry.attach(
        "timber-ecto-query-handler",
        [:store, :repo, :query],
        &Timber.Ecto.handle_event/4,
        query_time_ms_threshold: 2_000,
        log_level: :info
      )

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Store.Repo, []),
      worker(Store.Scheduler, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Store.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
