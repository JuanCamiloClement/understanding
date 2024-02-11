defmodule Understanding.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UnderstandingWeb.Telemetry,
      Understanding.Repo,
      {DNSCluster, query: Application.get_env(:understanding, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Understanding.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Understanding.Finch},
      # Start a worker by calling: Understanding.Worker.start_link(arg)
      # {Understanding.Worker, arg},
      # Start to serve requests, typically the last entry
      UnderstandingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Understanding.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UnderstandingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
