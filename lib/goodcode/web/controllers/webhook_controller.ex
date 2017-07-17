defmodule GC.Web.WebhookController do
  use GC.Web, :controller

  require Logger
  @webhook_secret System.get_env("GC_WEBHOOK_SECRET")
  def github_sync(conn, params) do
    Logger.info "running github sync #{inspect params}"
    text conn, "ok"
  end

end
