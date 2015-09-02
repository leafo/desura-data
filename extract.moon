
import Pages, QueuedUrls from require "moonscrape.models"
import query_all from require "web_sanitize.query"

import DailyViews from require "models"
import bulk_insert from require "helpers.model"

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
      {1, game_id, date, views}

    print "Inserting game #{game_id}"
    bulk_insert DailyViews, {"object_type", "object_id", "date", "count"}, tuples
    -- os.exit!
