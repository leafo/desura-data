source("common.r")

png(file="game_monthly_views.png", width=1500, height=700, res=120)
op <- par(mar=c(5, 2, 2, 6), lwd=2)

res <- dbGetQuery(con, "
  select date_trunc('month', date) sum_month, sum(count) from daily_views
  group by sum_month
  order by sum_month asc
")

res$sum_month <- as.Date(res$sum_month)

plot(res$sum,
     type="b", # dots and lines
     main="Views to game per month",
     xlab="",
     ylab="",
     axes=FALSE)

months_axis(res$sum_month)
count_axis(res$sum)

