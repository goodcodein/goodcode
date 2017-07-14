defmodule Repo.Post do
  alias __MODULE__

  @type t :: %__MODULE__{
    title: String.t,
    tags: list(String.t),
    body: String.t,
    github_url: String.t,
    github_path: String.t,
    file_content: String.t,
  }
  defstruct title: "", tags: [], body: "", github_url: "", github_path: "", file_content: ""
  def url(%Post{github_path: path}) do
    [subdomain, post_path] = path |> String.split("/")
    {subdomain, post_path |> String.replace_suffix(".md", "")}
  end
end
