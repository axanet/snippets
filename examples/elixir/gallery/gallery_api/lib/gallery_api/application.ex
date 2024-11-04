defmodule GalleryApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GalleryApiWeb.Telemetry,
      GalleryApi.Repo,
      {DNSCluster, query: Application.get_env(:gallery_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GalleryApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: GalleryApi.Finch},
      # Start a worker by calling: GalleryApi.Worker.start_link(arg)
      # {GalleryApi.Worker, arg},
      # Start to serve requests, typically the last entry
      GalleryApiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GalleryApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GalleryApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
