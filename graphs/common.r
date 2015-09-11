library("RPostgreSQL", quiet=TRUE)
con <- dbConnect(PostgreSQL(), user="postgres", dbname="desura_data")

axis_color <- rgb(0.7,0.7,0.7)
primary_color <- "#DD4A4A"

default_width <- 1000
default_height <- 600
default_height_half <- 400

colors <- rainbow(8)


format_months <- function(months) {
  strftime(months, "%b %y")
}

months_axis <- function(months, skip=TRUE) {
  month_ids <- seq(1, length(months))

  if (skip) {
    month_ids <- unique(c(seq(1, length(months), 3), length(months)))
  }

  axis(1,
       col=axis_color,
       las=2,
       at=month_ids,
       labels=format_months(months[month_ids]))
}


axis_stops <- function(max, chunks, nearest=FALSE, log_scale=FALSE, min=0) {
  if (log_scale) {
    max <- log10(max)
  }

  step <- max / chunks
  stops <- seq(0, max, step)

  if (log_scale) {
    stops <- 10^stops
    max <- 10^max
    step <- 10^max
  }

  if (nearest) {
    stops <- floor(stops / nearest) * nearest
  }

  stops <- unique(c(min, stops, max))

  if (do.call(`-`, as.list(rev(tail(stops, n=2)))) < step) {
    # remove second to last item
    stops = stops[-length(stops) + 1]
  }

  stops
}

count_axis <- function(counts) {
  stops <- axis_stops(max(res$sum), 4)
  axis(4,
       at=stops,
       labels=format(floor(stops), trim=TRUE, big.mark=",", scientific=FALSE),
       las=2)
}
