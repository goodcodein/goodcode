defmodule GC.Web.WebhookController do
  use GC.Web, :controller

  def github_sync(conn, _params) do
    text conn, "OK"
  end

end
