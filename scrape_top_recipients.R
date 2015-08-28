library("rvest")
library("magrittr")

url <- "http://farm.ewg.org/"
s <- html_session("http://farm.ewg.org/top_recips.php?fips=41000&progcode=totalfarm&page=0")

scrape_tables <- function(session, filename) {
  print(session)
  
  t <- session %>%
    html_node("#top_recip_table") %>%
    html_table()
  
  write.table(t,
              file = filename,
              col.names = FALSE,
              row.names = FALSE,
              append = TRUE,
              sep = ",")
  
  next_page <- session %>%
    html_nodes("strong a") %>%
    html_attr("href") %>%
    XML::getRelativeURL(url)
  s <- html_session(next_page)
  
  scrape_tables(s, filename)
}

scrape_tables(s, "top_recipients.csv")
