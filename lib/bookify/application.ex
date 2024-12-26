defmodule Bookify.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    File.mkdir_p!(Bookify.Utils.Upload.uploads_dir())

    children = [
      # Start the Telemetry supervisor
      BookifyWeb.Telemetry,
      # Start the Ecto repository
      Bookify.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Bookify.PubSub},
      # Start Finch
      {Finch, name: Bookify.Finch},
      # Start the Endpoint (http/https)
      BookifyWeb.Endpoint,
      # Start a worker by calling: Bookify.Worker.start_link(arg)
      # {Bookify.Worker, arg}
      {Task.Supervisor, name: Bookify.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bookify.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BookifyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
