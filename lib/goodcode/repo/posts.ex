defmodule Repo.Posts do
  @moduledoc """
  This is a GenServer which is spawned when the application starts and contains
  the state that is needed to respond to post requests
  """

  use GenServer

  @posts_tab :posts_tab
  @subdomains_posts_tab :subdomains_posts_tab

  # client api
  alias Repo.Post

  @doc """
  returns a list of all the posts in this subdomain
  """
  @spec all(String.t) :: list(Post.t)
  def all(subdomain) do
    :ets.lookup(@subdomains_posts_tab, subdomain)
    |> Enum.flat_map(fn {_, url} ->
      :ets.lookup(@posts_tab, url)
    end)
  end
  # end of client api

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # this is a blocking which is fine, as we are preparing our critical data
    {:ok, init_state()}
  end

  # gets all our posts and renders them properly for later use
  defp init_state() do
    :ets.new(@posts_tab, [:named_table, :set, :public,
                          {:write_concurrency, true}, {:read_concurrency, true}])
    :ets.new(@subdomains_posts_tab, [:named_table, :bag, :public,
                          {:write_concurrency, true}, {:read_concurrency, true}])

    Repo.GithubRepo.all
    |> Enum.each(fn post ->
      {subdomain, _} = post_url = Post.url(post)
      :ets.insert(@subdomains_posts_tab, {subdomain, post_url})
      :ets.insert(@posts_tab, {post_url, post})
    end)
  end
end
