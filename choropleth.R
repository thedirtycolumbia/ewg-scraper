# scrape Oregon County Rankings page and create choropleth of USDA subsidies by county

library("choroplethr")
library("choroplethrMaps")
library("magrittr")
library("rvest")
library("tidyr")

session <- html_session("http://farm.ewg.org/progdetail.php?fips=41000&progcode=total&page=county&regionname=Oregon")

df <- session %>%
  html_node("#top_x_table") %>%
  html_table()

df$href <- session %>%
  html_node("#top_x_table") %>%
  html_nodes("td a") %>%
  html_attr("href")

names(df) <- c("rank", "county", "usda_subsidies", "pct_total", "running_pct", "href")

# choroplethr needs these columns and column names
df$region <- tidyr::extract_numeric(df$href)*100000
df$value <- tidyr::extract_numeric(df$usda_subsidies)

# choroplethr doesn't like the Oregon NRCS fips
df <- subset(df, region != 41998)

county_choropleth(df,
                  title = "Total USDA - Subsidies in Oregon by County, 1995-2012",
                  legend = "Total USDA Subsidies 1995-2012",
                  buckets = 7,
                  zoom = "oregon")
