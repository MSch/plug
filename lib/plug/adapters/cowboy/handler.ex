defmodule Plug.Adapters.Cowboy.Handler do
  @moduledoc false
  @behaviour :cowboy_http_handler
  @connection Plug.Adapters.Cowboy.Conn

  def init({transport, :http}, req, {plug, opts}) when transport in [:tcp, :ssl] do
    {:ok, req, {transport, plug, opts}}
  end

  def handle(req, {transport, plug, opts}) do
    case plug.call(@connection.conn(req, transport), opts) do
      %Plug.Conn{adapter: {@connection, req}} ->
        {:ok, req, nil}
      other ->
        raise "Cowboy adapter expected #{inspect plug} to return Plug.Conn but got: #{inspect other}"
    end
  end

  def terminate(_reason, _req, nil) do
    :ok
  end
end
