defmodule Streamproc do
  def start() do
    WorkerPoolManager.start_link()
    LoadBalancer.start_link()
    ReaderSuper.start_link()
  end
end
