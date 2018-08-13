defmodule KioskNerves.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.Project.config()[:target]

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    # WebengineKiosk.go_to_url(kiosk, "file:///var/www/index.html")

    opts = [strategy: :one_for_one, name: KioskNerves.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  # def children("host") do
  #   [
  #     # Starts a worker by calling: KioskNerves.Worker.start_link(arg)
  #     # {KioskNerves.Worker, arg},
  #   ]
  # end

  def children(_target) do
    webengine_opts = Application.get_all_env(:webengine_kiosk)
    [
      {WebengineKiosk, {webengine_opts, name: Display}}
    ]
  end
end
