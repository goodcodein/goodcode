defmodule Repo.Post do
  alias __MODULE__

  @type t :: %__MODULE__{
    id: String.t,
    folder: String.t,
    title: String.t,
    tags: list(String.t),
    body: String.t,
    github_url: String.t,
    github_path: String.t,
    file_content: String.t,
  }
  defstruct id: "", folder: "", title: "", tags: [], body: "", github_url: "", github_path: "", file_content: ""
  def url(%Post{github_path: path}) do
    [subdomain, post_path] = path |> String.split("/")
    {subdomain, post_path |> String.replace_suffix(".md", "")}
  end

  def parse(%Post{} = post, contents) do
    [front_matter, body] = contents |> String.split("---", parts: 2, trim: true)
    %{'id' => id, 'title' => title, 'date' => date_str, 'tags' => tags} = :yamerl.decode(front_matter) |> hd |> Map.new

    {:ok, date, _} = ((date_str |> to_string) <> "T00:00:00Z") |> DateTime.from_iso8601

    {:ok, Map.merge(post, %{
      id: to_string(id),
      title: to_string(title),
      folder: Path.dirname(post.github_path),
      date: date,
      tags: tags |> Enum.map(&to_string/1),
      body: render_html(body),
    })}
  end

  defp render_html(body) do
    {:ok, html, []} = Earmark.as_html(body, %Earmark.Options{gfm: true, breaks: false})
    html
  end
end
