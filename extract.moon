
import Pages, QueuedUrls from require "moonscrape.models"
import query_all from require "web_sanitize.query"

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
    titles = query_all url.page.body, "data_set title"
    titles = [t\inner_html! for t in *titles]

    csv = query_all url.page.body, "data_set csv data"
    csv = [t\inner_html! for t in *csv]

    datasets = {}
    for i,title in pairs titles
      title = title\lower!\gsub ":$", ""
      datasets[title] = csv[i]

    print datasets.visitors

    os.exit!
