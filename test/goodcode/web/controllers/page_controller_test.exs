defmodule GC.Web.PageControllerTest do
  use GC.Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "goodcode"
  end
end
