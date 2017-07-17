defmodule GC.Web.WebhookController do
  use GC.Web, :controller

  require Logger
  def github_sync(conn, _params) do
    Logger.info "webhook received"
    spawn(fn -> Repo.GithubRepo.sync  end)
    text conn, "ok"
  end

end
