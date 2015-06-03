defmodule Plug.RequestIdTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defp call(conn, opts) do
    Plug.RequestId.call(conn, Plug.RequestId.init(opts))
  end

  test "generates new request id if none exists" do
    conn = conn(:get, "/") |> call([])
    [res_request_id] = conn |> get_resp_header("x-request-id")
    meta_request_id = Logger.metadata[:request_id]
    assert generated_request_id?(res_request_id)
    assert res_request_id == meta_request_id
  end

  test "generates new request id if existing one is invalid" do
    request_id = "tooshort"
    conn =
      conn(:get, "/")
      |> put_req_header("x-request-id", request_id)
      |> call([])
    [res_request_id] = conn |> get_resp_header("x-request-id")
    meta_request_id = Logger.metadata[:request_id]
    assert res_request_id != request_id
    assert generated_request_id?(res_request_id)
    assert res_request_id == meta_request_id
  end

  test "uses existing request id" do
    request_id = "existingidthatislongenough"
    conn =
      conn(:get, "/")
      |> put_req_header("x-request-id", request_id)
      |> call([])
    [res_request_id] = conn |> get_resp_header("x-request-id")
    meta_request_id = Logger.metadata[:request_id]
    assert res_request_id == request_id
    assert res_request_id == meta_request_id
  end

  test "generates new request id in custom header" do
    conn = conn(:get, "/") |> call(http_header: "custom-request-id")
    [res_request_id] = conn |> get_resp_header("custom-request-id")
    meta_request_id = Logger.metadata[:request_id]
    assert Regex.match?(~r/^[a-z0-9=]+$/u, res_request_id)
    assert res_request_id == meta_request_id
  end

  test "uses existing request id in custom header" do
    request_id = "existingidthatislongenough"
    conn =
      conn(:get, "/")
      |> put_req_header("custom-request-id", request_id)
      |> call(http_header: "custom-request-id")
    [res_request_id] = conn |> get_resp_header("custom-request-id")
    meta_request_id = Logger.metadata[:request_id]
    assert res_request_id == request_id
    assert res_request_id == meta_request_id
  end

  defp generated_request_id?(request_id) do
    Regex.match?(~r/^[a-z0-9=]+$/u, request_id)
  end
end
