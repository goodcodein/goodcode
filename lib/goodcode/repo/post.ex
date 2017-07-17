defmodule Repo.Post do
  alias __MODULE__

  @type t :: %__MODULE__{
    id: String.t,
    folder: String.t,
    title: String.t,
    tags: list(String.t),
    body: String.t,
    date: DateTime.t,
    github_path: String.t,
  }
  defstruct id: "", folder: "", title: "", tags: [], body: "", date: nil, github_path: ""
  def url(%Post{github_path: path}) do
    path
  end

  @spec parse(filepath :: String.t, contents :: String.t) :: Post.t
  def parse(filepath, contents) do
    folder = filepath |> Path.dirname |> Path.basename
    filename = Path.basename(filepath)
    [front_matter, body] = contents |> String.split("---", parts: 2, trim: true)

    %{'id' => id, 'title' => title, 'date' => date_str, 'tags' => tags} = :yamerl.decode(front_matter) |> hd |> Map.new

    {:ok, date, _} = ((date_str |> to_string) <> "T00:00:00Z") |> DateTime.from_iso8601

    {:ok, %Post{
      id: to_string(id),
      title: to_string(title),
      folder: folder,
      github_path: Path.join(["/", folder, filename]),
      date: date,
      tags: tags |> Enum.map(&to_string/1),
      body: render_html(body),
    }}
  end

  defp render_html(body) do
    {:ok, html, []} = Earmark.as_html(body, %Earmark.Options{gfm: true, breaks: false})
    html
  end
end
