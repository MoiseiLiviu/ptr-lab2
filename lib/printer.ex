defmodule Printer do
  use GenServer

  @min_sleep_time 5
  @max_sleep_time 50

  def start_link(id) do
    IO.puts "Starting printer..."
    GenServer.start_link(__MODULE__, id)
  end

  def init(id) do
    {:ok, id}
  end

  def print(pid, msg) do
    GenServer.cast(pid, msg)
  end

  def handle_cast(:kill, state) do
    IO.puts("## Killing printer ##")
    {:stop, :normal, state}
  end

  def handle_cast(msg, state) do
    sleep_randomly()
    msg = filter_bad_words(msg)
    IO.inspect(self())
    IO.puts(msg)
    {:noreply, state}
  end

  defp filter_bad_words(msg) do
    msg = URI.encode(msg)
    HTTPoison.get!("https://www.purgomalum.com/service/plain?text=#{msg}")
    |> Map.get(:body)
  end

  defp sleep_randomly do
    sleep_time = :rand.uniform(@max_sleep_time - @min_sleep_time) + @min_sleep_time
    Process.sleep(sleep_time)
  end
end