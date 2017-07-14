defmodule GC.Web.PageController do
  use GC.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
