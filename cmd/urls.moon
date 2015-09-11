

import Pages, QueuedUrls from require "moonscrape.models"
pager = QueuedUrls\paginated per_page: 1000
for urls in pager\each_page!
  for url in *urls
    continue unless url.status == QueuedUrls.statuses.complete
    print url.url

