defmodule GC.Web.PageView do
  use GC.Web, :view

  alias Repo.Post

  def post_url(%Post{id: id, title: title, folder: folder}) do
    "/#{folder}/#{id}/#{slugify(title)}"
  end

  @slug_rx ~r/[^a-z0-9]+/
  defp slugify(title) do
    title
    |> String.downcase
    |> String.replace(@slug_rx, "-")
    |> String.trim("-")
  end
end
