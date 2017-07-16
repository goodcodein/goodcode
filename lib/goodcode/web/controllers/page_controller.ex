defmodule GC.Web.PageController do
  use GC.Web, :controller
  alias Repo.Posts

  def index(conn, _params) do
    render conn, "index.html", posts: Repo.Posts.all(), title: "Idiomatic and useful code"
  end

  def tag(conn, params) do
    tag = params["tag"]
    if tag do
      conn
      |> render("list.html", posts: Repo.Posts.for_tags(tag), title: "Posts tagged ##{tag}")
    else
      conn
      |> put_flash(:warn, "Tag not found")
      |> redirect(to: "/")
    end
  end

  def tags(conn, _) do
    render conn, "tags.html", tags: Repo.Posts.all_tags, title: "All tags"
  end

  def archives(conn, _) do
    render conn, "archives.html", posts: Repo.Posts.all, title: "Archives"
  end

  def show(conn, %{"id" => id, "folder" => folder}) do
    post = Posts.find_by_id(folder, id)
    render conn, "show.html", post: post, title: post.title,
      canonical_path: GC.Web.PageView.post_url(post)
  end

  def permalink(conn, %{"id" => id, "folder" => folder}) do
    post = Posts.find_by_id(folder, id)
    redirect(conn, to: GC.Web.PageView.post_url(post))
  end
end
