defmodule LoadBalancer do
  use GenServer

  @nr_of_workers 3

  def start_link do
    IO.puts "Starting load balancer..."
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    Enum.each(1..@nr_of_workers, fn _i ->
      PrinterSuper.start_new_printer()
    end)
    {:ok, state}
  end

  def get_least_busy_worker do
    GenServer.call(__MODULE__, :get_least_busy_worker)
  end

  def handle_call(:get_least_busy_worker, _from, _state) do
    pid = PrinterSuper.get_least_connected() |> elem(0)
    {:reply, pid, nil}
  end
end