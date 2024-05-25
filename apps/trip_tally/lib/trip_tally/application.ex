defmodule TripTally.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TripTally.Repo,
      {DNSCluster, query: Application.get_env(:trip_tally, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TripTally.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: TripTally.Finch}
      # Start a worker by calling: TripTally.Worker.start_link(arg)
      # {TripTally.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: TripTally.Supervisor)
  end
end
