defmodule Streamproc do
  def start() do
    PrinterSuper.start_link()
    LoadBalancer.start_link()
    ReaderSuper.start_link()
  end
end
