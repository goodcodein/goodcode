defmodule Repo.GithubRepo do
  alias Repo.Post
  alias Tentacat.Contents, as: TC

  import Logger, only: [info: 1]
  @repo_dir Application.get_env(:goodcode, :repo_dir)
  @repo_url Application.get_env(:goodcode, :repo_url)
  @spec sync(String.t, String.t) :: any
  def sync(repo_url \\ @repo_url, repo_dir \\ @repo_dir) do
    ensure_cloned repo_url, repo_dir
    pull repo_dir
  end

  @spec files(repo_dir :: String.t) :: [String.t]
  def files(repo_dir \\ @repo_dir) do
    Path.wildcard("#{repo_dir}/**/*.md")
  end

  #@spec ensure_cloned(String.t) :: any
  defp ensure_cloned(repo_url, repo_dir) do
    if !File.dir?(repo_dir) do
      run ~s[git clone "#{repo_url}" "#{repo_dir}"]
    end
  end

  @spec pull(String.t) :: any
  defp pull(repo_dir) do
    run ~s[cd #{repo_dir}; git pull origin master:master]
  end

  @spec run(cmd :: String.t) :: any
  defp run(cmd) do
    info "running cmd> #{cmd}"
    cmd |> to_charlist |> :os.cmd |> IO.puts
  end


  def all do
    client = client()
    get_contents(client)
  end

  @owner "goodcodein"
  @repo "goodcode.in"
  defp get_contents(client) do
    TC.find(@owner, @repo, _path = "", client)
    |> Enum.filter(& match? %{"type" => "dir"}, &1)
    |> Enum.flat_map(fn %{"path" => subdomain_path} ->
      # TODO: add pagination
      TC.find(@owner, @repo, subdomain_path, client)
      |> Enum.map(fn %{"html_url" => html_url, "path" => path, "type" => "file"} ->
        {:ok, content} = download_post(@owner, @repo, path, client)
        {:ok, post} =
          %Post{
            github_url: html_url,
            github_path: path,
            file_content: content,
          } |> Post.parse(content)
        post
      end)
    end)
  end

  defp download_post(owner, repo, path, client) do
    %{"content" => content, "encoding" => "base64"} = TC.find(owner, repo, path, client)
    Base.decode64(content, ignore: :whitespace)
  end

  @access_token System.get_env["GOODCODE_GH_ACESS_TOKEN"]
  defp client do
    %Tentacat.Client{auth: %{access_token: @access_token}}
  end

end

# sample response
# [%{"_links" => %{"git" => "https://api.github.com/repos/goodcodein/goodcode.in/git/blobs/aa96784456d24d0a7511f08aaaab5d2ff0ec45a6",
#      "html" => "https://github.com/goodcodein/goodcode.in/blob/master/README",
#      "self" => "https://api.github.com/repos/goodcodein/goodcode.in/contents/README?ref=master"},
#    "download_url" => "https://raw.githubusercontent.com/goodcodein/goodcode.in/master/README",
#    "git_url" => "https://api.github.com/repos/goodcodein/goodcode.in/git/blobs/aa96784456d24d0a7511f08aaaab5d2ff0ec45a6",
#    "html_url" => "https://github.com/goodcodein/goodcode.in/blob/master/README",
#    "name" => "README", "path" => "README",
#    "sha" => "aa96784456d24d0a7511f08aaaab5d2ff0ec45a6", "size" => 10,
#    "type" => "file",
#    "url" => "https://api.github.com/repos/goodcodein/goodcode.in/contents/README?ref=master"},
#  %{"_links" => %{"git" => "https://api.github.com/repos/goodcodein/goodcode.in/git/trees/d0fa71cad2bc6326be014c6ea87402fa2b55319a",
#      "html" => "https://github.com/goodcodein/goodcode.in/tree/master/phoenix",
#      "self" => "https://api.github.com/repos/goodcodein/goodcode.in/contents/phoenix?ref=master"},
#    "download_url" => nil,
#    "git_url" => "https://api.github.com/repos/goodcodein/goodcode.in/git/trees/d0fa71cad2bc6326be014c6ea87402fa2b55319a",
#    "html_url" => "https://github.com/goodcodein/goodcode.in/tree/master/phoenix",
#    "name" => "phoenix", "path" => "phoenix",
#    "sha" => "d0fa71cad2bc6326be014c6ea87402fa2b55319a", "size" => 0,
#    "type" => "dir",
#    "url" => "https://api.github.com/repos/goodcodein/goodcode.in/contents/phoenix?ref=master"}]

