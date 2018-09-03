defmodule NervesKiosk.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.Project.config()[:target]

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options

    platform_init(@target)

    webengine_kiosk_opts =
      Application.get_all_env(:webengine_kiosk)

    children = [
      {WebengineKiosk, {webengine_kiosk_opts, [name: Display]}}
    | children(@target)]

    opts = [strategy: :one_for_one, name: NervesKiosk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children("host") do
    [
      # Starts a worker by calling: NervesKiosk.Worker.start_link(arg)
      # {NervesKiosk.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Starts a worker by calling: NervesKiosk.Worker.start_link(arg)
      # {NervesKiosk.Worker, arg},
    ]
  end

  defp platform_init("host"), do: :ok

  defp platform_init(_target) do
    # Initialize udev
    :os.cmd('udevd -d');
    :os.cmd('udevadm trigger --type=subsystems --action=add');
    :os.cmd('udevadm trigger --type=devices --action=add');
    :os.cmd('udevadm settle --timeout=30');
    # Workaround a known bug with HTML5 canvas and rpi gpu
    System.put_env("QTWEBENGINE_CHROMIUM_FLAGS", "--disable-gpu")
  end
end
