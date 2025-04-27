generate_weekly_post <- function(yr, week_num, force_update = FALSE) {
  # Filter links for the week
  week_links <- links[links$year == yr & links$week_number == week_num, ]
  
  if (nrow(week_links) == 0) {
    message("No links found for week ", week_num, ", ", yr)
    return(invisible())
  }
  
  # Format week number and create filename
  week_formatted <- sprintf("%02d", week_num)
  if (!dir.exists("links")) dir.create("links")
  filename <- file.path("links", sprintf("%s-W%s.qmd", yr, week_formatted))
  
  # Skip if file exists
  if (file.exists(filename) && !force_update) {
    message("File exists. Skipping: ", filename)
    return(invisible())
  }
  
  # Create YAML header
  yaml_header <- sprintf("---\ntitle: \"%s-W%s\"\n---\n\n", yr, week_formatted)
  
  # Generate content
  content <- character()
  for (i in seq_len(nrow(week_links))) {
    link <- week_links[i, ]
    
    # Build properly formatted link line
    if ("category" %in% names(link) && !is.na(link$category) && nzchar(link$category)) {
      link_text <- sprintf("- [%s] [%s](%s)", 
                           link$category, 
                           link$title, 
                           link$url)
    } else {
      link_text <- sprintf("- [%s](%s)", link$title, link$url)
    }
    
    # Add description if present (with proper Markdown formatting)
    if ("description" %in% names(link) && !is.na(link$description) && nzchar(link$description)) {
      link_text <- paste0(link_text, "\n\n  ", link$description)
    }
    
    content <- c(content, link_text, "")
  }
  
  # Write file
  writeLines(c(yaml_header, content), filename, useBytes = TRUE)
  message("Created: ", filename)
}

# Main execution
tryCatch({
  # Read and validate data
  links <- read.csv("links_database.csv", encoding = "UTF-8", stringsAsFactors = FALSE)
  
  # Check required columns
  required <- c("year", "week_number", "title", "url")
  missing <- setdiff(required, names(links))
  if (length(missing)) stop("Missing required columns: ", paste(missing, collapse = ", "))
  
  # Process each week
  weeks <- unique(links[c("year", "week_number")])
  for (i in seq_len(nrow(weeks))) {
    generate_weekly_post(weeks$year[i], weeks$week_number[i])
  }
}, error = function(e) {
  stop("Error: ", e$message, call. = FALSE)
})