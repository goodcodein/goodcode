defmodule GC.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(GC.Web.Endpoint, []),
      # Start your own worker by calling: GC.Worker.start_link(arg1, arg2, arg3)
      # worker(GC.Worker, [arg1, arg2, arg3]),
      worker(Repo.Posts, []),
      worker(Task, [&Repo.GithubRepo.sync/0], restart: :temporary),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GC.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
