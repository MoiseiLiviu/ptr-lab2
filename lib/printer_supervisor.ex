defmodule PrinterSuper do
  use DynamicSupervisor

  @min_workers 3
  @max_workers 10
  @high_task_threshold 30
  @low_task_threshold 5

  def start_link do
    IO.puts("PrintSuper started")
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def get_least_connected() do
    adjust_worker_count()

    least_connected_pid =
      DynamicSupervisor.which_children(__MODULE__)
      |> Enum.map(fn x -> elem(x, 1) end)
      |> Enum.min_by(fn x -> Process.info(x, :message_queue_len) end)

    case Process.info(least_connected_pid, :message_queue_len) do
      {:message_queue_len, messages_count} -> {least_connected_pid, messages_count}
      nil -> get_least_connected()
    end
  end

  def print(msg) do
    pid = get_least_connected()
    Printer.print(pid, msg)
    adjust_worker_count()
  end

  def start_new_printer do
    IO.puts "New id : #{new_id}}"
    new_id = count() + 1
    IO.puts "New id : #{new_id}}"
    DynamicSupervisor.start_child(__MODULE__, %{
      id: new_id,
      start: {Printer, :start_link, []}
    })
  end

  defp adjust_worker_count do
    nr_of_workers = count()

    nr_of_requests =
      DynamicSupervisor.which_children(__MODULE__)
      |> Enum.map(fn x -> Process.info(x, :message_queue_len) end)
      |> Enum.reduce(0, fn {_, v}, acc -> acc + v end)

    avg_requests = nr_of_requests / nr_of_workers

    cond do
      avg_requests >= @high_task_threshold and count() < @max_workers ->
        start_new_printer()

      avg_requests <= @low_task_threshold and count() > @min_workers ->
        {least_connected_pid, _messages_count} = get_least_connected()
        remove_worker(least_connected_pid)

      true ->
        :ok
    end
  end

  defp get_worker_messages(pid) do
    {:messages, messages} = Process.info(pid, :messages)
    Enum.map(messages, fn {_, msg} -> msg end)
  end

  def count() do
    DynamicSupervisor.count_children(__MODULE__)
  end

  defp remove_worker(pid) do
    messages = get_worker_messages(pid)
    DynamicSupervisor.terminate_child(__MODULE__, pid)
    Enum.each(messages, fn msg -> print(msg) end)
  end
end
