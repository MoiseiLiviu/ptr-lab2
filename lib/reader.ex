defmodule Reader do
  use GenServer

  def init(url) do
    IO.puts("Starting reader")
    EventsourceEx.new(url, stream_to: self())
  end

  def handle_info(message, state) do
    process_event(message)
    {:noreply, state}
  end

  def start_link(url \\ []) do
    GenServer.start_link(__MODULE__, url)
  end

  defp process_event(%EventsourceEx.Message{:data => message}) do
    case Jason.decode(String.trim(message)) do
      {:ok, data} ->
        tweet = data["message"]["tweet"]
        text = tweet["text"]
        PrinterSuper.print(text)

      {:error, _} ->
        PrinterSuper.print(:kill)
    end
  end

  defp process_event(_) do
    PrinterSuper.print(:kill)
  end
end
