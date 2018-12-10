defmodule Console do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Console.ProgramsServer, []),
      worker(Console.PidsWorker, []),
    ]

    opts = [strategy: :one_for_one, name: Console.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
