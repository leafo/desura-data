import Scraper from require "moonscrape"
import is_relative_url, decode_html_entities from require "moonscrape.util"
import query_all from require "web_sanitize.query"

pcre = require "rex_pcre"

desura = ->
  scraper = Scraper {
    project: "desura"
    sleep: {0.2, 1.0}

    url_priority: (url) =>
      if pcre.match url, [[/games/browse\b]]
        return 1

      -- get games first
      if pcre.match url, [[/games/[^/]+$]]
        return 2

      -- get game's stat pages second
      if pcre.match url, [[/games/[^/]+/stats$]]
        return 1

      -- get the stats
      if url\match "rss%.desura%.com"
        return 1

      -- multiple page stuff less important
      if pcre.match url, [[/page/]]
        return -1

      return 0

    filter_page: (queued_url, ...) =>
      return true if queued_url.url\match "%.xml$"
      Scraper.filter_page @, queued_url, ...

    filter_url: (url) =>
      return false unless url\match("^(%w+):") == "http"

      return true if url\match "//rss%.desura%.com/statistics/feed/visitinternal/games"

      return false unless url\match "//www.desura.com/games"
      return false if pcre.match url, [[/play\b]]
      return false if pcre.match url, [[/messages\b]]
      return false if pcre.match url, [[/watchers\b]]
      return false if pcre.match url, [[/reviews\b]]
      return false if pcre.match url, [[/related/news\b]]
      return false if pcre.match url, [[/games/[^/]+/forum\b]]

      if pcre.match url, [[\butm_source=]]
        return false

      if pcre.match url, [[/members/login\b]]
        return false

      if pcre.match url, [[/games/browse\b]]
        -- only scrape the name asc games list
        return false unless url\match("?(.*)$") == "sort=name-asc"

      if pcre.match(url, [[/news\b]]) or pcre.match(url, [[/mods\b]])
        return false if url\match "?"

      true

    default_handler: (url, page) =>
      for link in *query_all page.body, "a"
        href = link.attr and link.attr.href
        href = type(href) == "string" and decode_html_entities href
        continue unless href
        url\queue href

      if pcre.match url.url, [[/games/[^/]+/stats$]]
        game_id = page.body\match "visitinternal/games/(%d+)/videos%-images%-articles"
        if game_id
          url\queue "http://rss.desura.com/statistics/feed/visitinternal/games/#{game_id}/videos-images-articles/feed/rss.xml"
  }

  scraper\queue "http://www.desura.com/games/browse?sort=name-asc"
  -- print "refilter", scraper\refilter_queued!
  -- print "requeue failed", scraper\requeue_failed!
  -- print "reprioritize", scraper\reprioritize_queued!
  -- print "rescan", scraper\rescan_complete!

  scraper\run!
  -- scraper\rescan_complete!

desura!
