# Go through each county / year summary page for a state and scrape the regional summary table 
library("rvest")
library("magrittr")
library("httr")
library("tidyr")

base_url <- "http://farm.ewg.org"

# top-level state summary page for Oregon
s <- html_session("http://farm.ewg.org/region.php?fips=41000")

# Scrape the region table from each year
scrape_table <- function(year_url) {
  s <- html_session(year_url)
  print(s)
  region_table <- s %>% html_node("#region_table")
  # The region table is missing for some years
  if (!is.null(region_table)) {
    table <- s %>% html_node("#region_table") %>% html_table()
    
    names(table) <- c("rank", "program", "region", "number_of_recipients", "year", "subsidy_total")
   
    # Create county and year columns from the URL params 
    table$region <- parse_url(year_url)$query$fips
    table$year <- parse_url(year_url)$query$yr
   
    # Remove extraneous characters from numeric columns
    table$number_of_recipients <- extract_numeric(table$number_of_recipients)
    table$subsidy_total <- extract_numeric(table$subsidy_total)

    # Extract crop names into a seperate column    
    table$crop <- gsub("([[:alpha:]]) Subsidies.*", "\\1", table$program)
    table$crop <- gsub("([[:alpha:]]) Program.*", "\\1", table$crop)
    table$crop <- gsub("Reserve|Incentive|Payment", NA, table$crop)
  
    write.table(table,
                file = "subsidies_by_region_and_year.csv",
                col.names = FALSE,
                row.names = FALSE,
                append = TRUE,
                sep = ",")  
  }
}

# Follow each year link from the region page and call scrape_table
scrape_by_year <- function(region_url) {
  s <- html_session(region_url)
  
  years <- s %>%
    html_node("#top_programs_summary") %>%
    html_nodes("li a") %>%
    html_attr("href")
  
  for (year in years) {
    year_url <- XML::getRelativeURL(year, base_url)
    scrape_table(year_url)
  }
}

# Follow each region link from the top-level state summary page and call scrape_by_year
regions <- s %>%
  html_node("select") %>%
  html_nodes("option") %>%
  html_attr("value")
regions <- subset(regions, regions != "")

for (region in regions) {
  region_url <- XML::getRelativeURL(region, base_url)
  scrape_by_year(region_url)
}
