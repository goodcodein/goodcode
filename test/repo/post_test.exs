defmodule PostTest do
  use ExUnit.Case
  alias Repo.Post

  test "parses front_matter" do
    post = %Post{}
    {:ok, contents} = File.read(Path.expand "../fixtures/post.md", __DIR__)
    {:ok, post} = Post.parse(post, contents)

    assert post.title ==
         "Annotating variables with underscore variables to make code more readable"
    assert post.tags == ["elixir", "readability"]
    {:ok, date, _} = DateTime.from_iso8601("2017-07-10T00:00:00Z")
    assert post.date == date
    assert post.id == "1"
    assert post.body ==
      """
      <p>We should always strive to make our code as readable as possible. Underscore variables
      aid is in making our code more readable by annotating literal values with meanings.</p>
      <p>Look at the following variations</p>
      <h2>without any underscore variable annotation</h2>
      <pre><code class="elixir">Tentacat.Contents.find(@owner, @repo, &quot;&quot;, client)</code></pre>
      <p>While reading the code, it is difficult to know what the third parameter is. In most these cases, I navigate to the actual function definition and read the variable name.</p>
      <h2>with underscore annotations</h2>
      <p>Here is an improved version of the same code with and underscore variable annotation. It makes it crystal clear that the third argument is a path.</p>
      <pre><code class="elixir">Tentacat.Contents.find(@owner, @repo, _path = &quot;&quot;, client)</code></pre>
      <p>What are the techniques you use in your code to make it more readable?</p>
      """
  end
end
