defmodule Repo.GithubRepo do
  alias Repo.Post

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
    run ~s[cd #{repo_dir}; git reset --hard HEAD && git clean -f -d && git pull]
  end

  @spec run(cmd :: String.t) :: any
  defp run(cmd) do
    info "running cmd> #{cmd}"
    cmd |> to_charlist |> :os.cmd |> IO.puts
  end

  def all do
    files()
    |> Enum.map(fn filepath ->
      {:ok, post} = Post.parse(filepath, File.read!(filepath))
      post
    end)
  end
end
