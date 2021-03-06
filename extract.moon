
db = require "lapis.db"

import Pages, QueuedUrls from require "moonscrape.models"
import query_all from require "web_sanitize.query"

import DailyViews, Games from require "models"
import bulk_insert from require "helpers.model"

views = ->
  pager = QueuedUrls\paginated "
    where project = 'desura' and url like '%rss.%'
    order by id asc
  ", {
    per_page: 1000
    prepare_results: (urls) ->
      Pages\include_in urls, "queued_url_id", flip: true
      urls
  }

  for group in pager\each_page!
    for url in *group
      game_id = tonumber url.url\match "games/(%d+)"
      assert game_id, "missing game id"

      game = Games\find remote_id: tostring game_id
      unless game
        print "Failed to find game for remote id: #{game_id}"
        continue

      titles = query_all url.page.body, "data_set title"
      titles = [t\inner_html! for t in *titles]

      csv = query_all url.page.body, "data_set csv data"
      csv = [t\inner_html! for t in *csv]

      datasets = {}
      for i,title in pairs titles
        title = title\lower!\gsub ":$", ""
        datasets[title] = csv[i]

      tuples = for line in datasets.visitors\gmatch "([^\n]+)"
        date, views = line\match "(%d+-%d+-%d+);(%d+)"
        continue unless date
        views = tonumber views
        {1, game.id, date, views}

      print "Inserting views for: #{game.slug}"
      bulk_insert DailyViews, {"object_type", "object_id", "date", "count"}, tuples
      -- os.exit!

games = ->
  pager = QueuedUrls\paginated "
    where project = 'desura' and url ~ '/games/[^/]+$'
    order by id asc
  ", {
    per_page: 1000
    prepare_results: (urls) ->
      Pages\include_in urls, "queued_url_id", flip: true
      urls
  }


  skipped = {}
  failed = {}

  for group in pager\each_page!
    for url in *group
      continue if url.url\match "%s"

      print url.url
      page = url\get_page!
      continue unless page

      local game_id
      meta = query_all url.page.body, "meta"
      for m in *meta
        if c = m.attr.content
          game_id = c\match "images/games/%d+/%d+/(%d+)"
          break if game_id

      title = unpack query_all url.page.body, ".title h2 a"
      title = title and title\inner_html!

      unless title and game_id
        print "Failed to get title/game_id #{title} #{game_id}"
        table.insert skipped, url.url
        continue

      inserted, err = pcall ->
        Games\create {
          queued_url_id: url.id
          url: url.url
          slug: url.url\match "([^/]+)$"
          remote_id: game_id
          title: title
        }

      unless inserted
        table.insert failed, {url.url, err}

  print!
  print "Skipped:"
  for url in *skipped
    print "  #{url}"

  print!
  print "Failed:"
  for {url, err} in *failed
    print "  #{url} - #{err}"


fn = ({
  :games
  :views
})[...]

unless fn
  error "Failed to provide action"

fn!

