defmodule GC.RssFeed do
  alias GC.RssFeed.Builder, as: B
  # w3c feed validatior: https://validator.w3.org/feed/#validate_by_input

  def xml(posts) do
    channel = B.channel("goodcode", Config.root_url, "Programming tips, Code samples, Code refactoring, Elixir, Phoenix",
                          (Timex.format! DateTime.utc_now, "{RFC1123z}"), "en-us")
    items = Enum.map(posts, fn post ->
      B.item(post.title, post.body, (Timex.format! post.date, "{RFC1123z}"), Path.join(Config.root_url, GC.Web.PageView.post_url(post)))
    end)
    _feed = B.feed(channel, items)
  end


  # copied from https://github.com/BennyHallett/elixir-rss
  defmodule Builder do

    def feed(channel, items) do
      """
      <?xml version="1.0" encoding="utf-8"?>
      <rss version="2.0">
      <channel>
      #{channel}#{Enum.join items, ""}</channel>
      </rss>
      """
    end

    def item(title, desc, pubDate, link) do
      """
      <item>
      <title>#{title}</title>
      <description><![CDATA[ #{desc} ]]></description>
      <pubDate>#{pubDate}</pubDate>
      <link>#{link}</link>
      </item>
      """
    end

    def channel(title, link, desc, date, lang) do
      """
      <title>#{title}</title>
      <link>#{link}</link>
      <description>#{desc}</description>
      <lastBuildDate>#{date}</lastBuildDate>
      <language>#{lang}</language>
      """
    end

  end
end

