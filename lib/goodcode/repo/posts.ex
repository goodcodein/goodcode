defmodule Repo.Posts do
  @moduledoc """
  This is a GenServer which is spawned when the application starts and contains
  the state that is needed to respond to post requests
  """

  use GenServer

  @posts_tab :posts_tab
  @tags_tab :tags_tab
  @subdomains_posts_tab :subdomains_posts_tab

  # client api
  alias Repo.Post

  @doc """
  returns a list of all the posts
  """
  @spec all() :: list(Post.t)
  def all do
    :ets.tab2list(@posts_tab)
    |> Enum.map(fn {_, post} -> post end)
  end

  @spec all_tags() :: [String.t]
  def all_tags do
    :ets.tab2list(@tags_tab)
    |> Enum.map(fn {tag, _} -> tag end)
  end

  @spec for_tags(String.t) :: list(Post.t)
  def for_tags(tag) do
    :ets.lookup(@tags_tab, tag)
    |> Enum.map(fn {_, url} -> for_url(url) end)
    |> Enum.filter(& &1)
  end

  @spec for_url({String.t, String.t}) :: Post.t
  def for_url(url) do
    case :ets.lookup(@posts_tab, url) do
      [{_, post}] -> post
      [] -> nil
    end
  end

  # end of client api

  @doc """
  returns a list of all the posts in this subdomain
  """
  @spec for_subdomain(String.t) :: list(Post.t)
  def for_subdomain(subdomain) do
    :ets.lookup(@subdomains_posts_tab, subdomain)
    |> Enum.flat_map(fn {_, url} ->
      case :ets.lookup(@posts_tab, url) do
        [{_url, post}] -> [post]
        _ -> []
      end
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
    :ets.new(@tags_tab, [:named_table, :bag, :public,
                          {:write_concurrency, true}, {:read_concurrency, true}])

    Repo.GithubRepo.all
    |> Enum.each(fn post ->
      {subdomain, _} = post_url = Post.url(post)
      :ets.insert(@subdomains_posts_tab, {subdomain, post_url})
      :ets.insert(@posts_tab, {post_url, post})
      post.tags |> Enum.each(fn tag ->
        :ets.insert(@tags_tab, {tag, post_url})
      end)
    end)
  end
end
