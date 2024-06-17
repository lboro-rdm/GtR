library(tidyverse)
library(httr)
library(jsonlite)

# URL for the organisation's projects
base_url <- "https://gtr.ukri.org/gtr/api/organisations/E4BC926F-50DE-44EE-AFEB-5A9C41512F4B/projects"

# Initialize list to store all projects data
all_projects <- list()
page <- 1
has_more_pages <- TRUE


# Fetch data from the API with pagination handling
while (has_more_pages) {
  # Construct paginated URL
  paged_url <- paste0(base_url, "?page=", page, "&fetchSize=100")
  response <- GET(paged_url)
  
  if (status_code(response) == 200) {
    content <- content(response, "text", encoding = "UTF-8")
    projects_data <- fromJSON(content, flatten = TRUE)
    
    # Append current page data to all_projects list
    all_projects <- append(all_projects, list(projects_data))
    
    # Check if there is a next page (you may need to adjust this based on API documentation)
    if (length(projects_data) == 0) {
      has_more_pages <- FALSE
    } else {
      page <- page + 1
      print(page)
    }
  } else {
    print(paste("Failed to fetch data on page", page, ". Status code:", status_code(response)))
    has_more_pages <- FALSE
  }
}

# Combine all pages into a single data frame
all_projects_df <- do.call(rbind, lapply(all_projects$project, as.data.frame))

# Convert the combined data frame to a tibble
projects_tibble <- as_tibble(all_projects_df)
