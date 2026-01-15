utils::globalVariables(c(
  "sector", "title_cleaned", "frequency_cleaned", "title_generalized", "title_type",
  "title_cleaned_length", "title_similarity"
))

#' Load and Augment Job Title Mapping Data
#'
#' Reads all sector-specific CSV files from the `dataset/titles/map` folder and combines them into one tidy dataframe,
#' adding advanced NLP features, summary statistics, and progress bar feedback.
#'
#' @param map_dir Path to the directory containing sector mapping CSV files (e.g., "~/cmap_data/dataset/titles/map").
#' @param columns Optional character vector of columns to select (default: NULL = all columns).
#' @param sector_filter Optional regex string to filter sectors (default: NULL = all sectors).
#' @param add_nlp Logical, add NLP-derived columns (title_type, title_similarity, etc.)? Default: TRUE.
#' @param summarize Logical, return sector-level summary statistics? Default: FALSE.
#' @param verbose Logical, print progress/messages? Default: TRUE.
#' @return A tibble with added variables and clean output, or a list if summarize=TRUE.
#' @details
#' Each file in `map_dir` should be named <sector>.csv and provide columns as described above.
#' The function now adds NLP-derived variables, sector-level summaries, and a progress bar.
#' See the accompanying publication for methodology.
#' @examples
#' title_map <- load_title_map("~/cmap_data/dataset/titles/map", add_nlp = TRUE, summarize = TRUE)
#' title_map$title_map %>% count(title_type)
#' title_map$sector_stats %>% arrange(desc(mean_length))
#' @importFrom purrr map_dfr
#' @importFrom readr read_csv
#' @importFrom dplyr mutate filter select group_by summarise n_distinct count arrange n
#' @importFrom janitor clean_names
#' @importFrom stringr str_replace_all str_detect str_count regex
#' @importFrom cli cli_progress_bar cli_progress_update cli_progress_done cli_alert_success cli_alert_info
#' @export
load_title_map <- function(
    map_dir,
    columns = NULL,
    sector_filter = NULL,
    add_nlp = TRUE,
    summarize = FALSE,
    verbose = TRUE
) {
  # Helper: Vectorized job title classifier
  classify_title_type <- function(title) {
    dplyr::case_when(
      stringr::str_detect(title, stringr::regex("manager|director|lead|chief|head|executive", ignore_case = TRUE)) ~ "Managerial",
      stringr::str_detect(title, stringr::regex("engineer|developer|analyst|scientist|technician", ignore_case = TRUE)) ~ "Technical",
      stringr::str_detect(title, stringr::regex("assistant|junior|intern|trainee", ignore_case = TRUE)) ~ "Entry-level",
      TRUE ~ "Other"
    )
  }
  
  # Helper: compute token-based Jaccard similarity
  compute_title_similarity <- function(title1, title2) {
    t1 <- unlist(strsplit(tolower(title1), "\\s+"))
    t2 <- unlist(strsplit(tolower(title2), "\\s+"))
    if (length(t1) == 0 || length(t2) == 0) return(NA_real_)
    length(intersect(t1, t2)) / length(union(t1, t2))
  }
  
  # Helper: sector-level summaries
  summarize_sector_titles <- function(df) {
    df %>%
      dplyr::group_by(sector, title_type) %>%
      dplyr::summarise(
        mean_length = mean(title_cleaned_length, na.rm = TRUE),
        top_title = title_cleaned[which.max(frequency_cleaned)],
        n_titles = dplyr::n(),
        total_titles = dplyr::n_distinct(title_cleaned),
        avg_similarity = mean(title_similarity, na.rm = TRUE),
        .groups = "drop"
      )
  }
  
  csv_files <- list.files(map_dir, pattern = "\\.csv$", full.names = TRUE)
  if (length(csv_files) == 0) stop("No CSV files found in ", map_dir)
  
  # Only use progress bar in interactive sessions
  if (interactive()) pb <- cli::cli_progress_bar("Reading title map files", total = length(csv_files))
  
  title_map <- purrr::map_dfr(csv_files, ~{
    if (interactive()) cli::cli_progress_update(pb)
    df <- readr::read_csv(.x, show_col_types = FALSE)
    # Add sector from filename if missing
    if (!"sector" %in% names(df)) {
      sector_name <- basename(.x) |> sub("\\.csv$", "", .)
      df <- dplyr::mutate(df, sector = sector_name)
    }
    df$source_file <- basename(.x)
    df
  })
  
  if (interactive()) cli::cli_progress_done(pb)
  
  # Clean column names
  title_map <- janitor::clean_names(title_map)
  
  # Filter by sector if needed
  if (!is.null(sector_filter)) {
    title_map <- dplyr::filter(title_map, stringr::str_detect(sector, sector_filter))
  }
  
  # Select columns if desired
  if (!is.null(columns)) {
    title_map <- dplyr::select(title_map, any_of(columns))
  }
  
  # NLP and derived columns
  if (add_nlp) {
    title_map <- title_map %>%
      dplyr::mutate(
        title_cleaned_length = nchar(title_cleaned),
        title_word_count = stringr::str_count(title_cleaned, "\\w+"),
        title_is_unique = !duplicated(title_cleaned),
        loaded_at = Sys.time(),
        title_type = classify_title_type(title_cleaned),
        title_similarity = mapply(compute_title_similarity, title_cleaned, title_generalized)
      )
  }
  
  # Optionally aggregate sector statistics
  if (summarize) {
    sector_stats <- summarize_sector_titles(title_map)
    result <- list(title_map = tibble::as_tibble(title_map), sector_stats = sector_stats)
    if (verbose && interactive()) {
      cli::cli_alert_success("Loaded {nrow(title_map)} rows from {length(csv_files)} files, {dplyr::n_distinct(title_map$sector)} sectors.")
      cli::cli_alert_info("Columns: {paste(names(title_map), collapse = ', ')}")
      cli::cli_alert_info("Sector summary available in result$sector_stats.")
    }
    return(result)
  }
  
  if (verbose && interactive()) {
    cli::cli_alert_success("Loaded {nrow(title_map)} rows from {length(csv_files)} files, {dplyr::n_distinct(title_map$sector)} sectors.")
    cli::cli_alert_info("Columns: {paste(names(title_map), collapse = ', ')}")
  }
  
  tibble::as_tibble(title_map)
}
