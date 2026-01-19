#' Load and Augment Sector-Specific Title Specialization Data
#'
#' Reads all sector-specific CSV files from the `titles/si` folder and combines them into a single tidy dataframe.
#' Adds NLP-derived features, sector-level summary statistics, and a progress bar for user feedback.
#'
#' @param si_dir Path to the directory containing sector CSV files (e.g., "~/cmap_data/titles/si").
#' @param columns Optional character vector of columns to select (default: NULL = all columns).
#' @param sector_filter Optional regex string to filter sectors (default: NULL = all sectors).
#' @param add_nlp Logical, add NLP-derived columns (title_type, title_length, etc.)? Default: TRUE.
#' @param summarize Logical, return sector-level summary statistics? Default: FALSE.
#' @param verbose Logical, print progress/messages? Default: TRUE.
#' @return A tibble with added variables and clean output, or a list if summarize=TRUE.
#' @details
#' Each file in `si_dir` must be named `<sector>.csv` and include columns:
#' sector, title, frequency, weighted_frequency, SE, SD, SI, onet_soc_codes.
#' The function now adds NLP-derived variables, sector-level summaries, and a progress bar.
#' See accompanying paper for metric methodology.
#' @examples
#' si_data <- load_sector_specialization("~/cmap_data/dataset/titles/si", add_nlp = TRUE, summarize = TRUE)
#' si_data$sector_stats |> dplyr::arrange(dplyr::desc(mean_title_length))
#' @importFrom purrr map list_rbind
#' @importFrom readr read_csv
#' @importFrom dplyr mutate filter select group_by summarise n_distinct count arrange n
#' @importFrom janitor clean_names
#' @importFrom stringr str_replace_all str_detect str_count regex
#' @export
load_sector_specialization <- function(
    si_dir,
    columns = NULL,
    sector_filter = NULL,
    add_nlp = TRUE,
    summarize = FALSE,
    verbose = TRUE
) {
  # classify_title_type() is defined in utils.R

  summarize_sector_titles <- function(df) {
    df |>
      dplyr::group_by(sector, title_type) |>
      dplyr::summarise(
        mean_title_length = mean(title_length, na.rm = TRUE),
        top_title = title[which.max(frequency)],
        n_titles = dplyr::n(),
        total_titles = dplyr::n_distinct(title),
        avg_si = mean(si, na.rm = TRUE),
        avg_sd = mean(sd, na.rm = TRUE),
        avg_se = mean(se, na.rm = TRUE),
        .groups = "drop"
      )
  }
  
  csv_files <- list.files(si_dir, pattern = "\\.csv$", full.names = TRUE)
  if (length(csv_files) == 0) {
    cli::cli_abort("No CSV files found in {.path {si_dir}}")
  }

  if (verbose && interactive()) {
    cli::cli_alert_info("Reading {length(csv_files)} sector specialization files...")
  }

  si_data <- purrr::map(csv_files, \(.x) {
    df <- readr::read_csv(.x, show_col_types = FALSE)
    if (!"sector" %in% names(df)) {
      sector_name <- sub("\\.csv$", "", basename(.x))
      df <- dplyr::mutate(df, sector = sector_name)
    }
    df$source_file <- basename(.x)
    df
  }) |> purrr::list_rbind()
  
  si_data <- janitor::clean_names(si_data)
  
  if (!is.null(sector_filter)) {
    si_data <- dplyr::filter(si_data, stringr::str_detect(sector, sector_filter))
  }
  
  if (!is.null(columns)) {
    si_data <- dplyr::select(si_data, any_of(columns))
  }
  
  if (add_nlp) {
    si_data <- si_data |>
      dplyr::mutate(
        title_length = nchar(title),
        title_word_count = stringr::str_count(title, "\\w+"),
        title_type = classify_title_type(title),
        loaded_at = Sys.time(),
        title_is_unique = !duplicated(title)
      )
  }
  
  if (summarize) {
    sector_stats <- summarize_sector_titles(si_data)
    result <- list(si_data = tibble::as_tibble(si_data), sector_stats = sector_stats)
    if (verbose && interactive()) {
      cli::cli_alert_success("Loaded {nrow(si_data)} rows from {length(csv_files)} files, {dplyr::n_distinct(si_data$sector)} sectors.")
      cli::cli_alert_info("Columns: {paste(names(si_data), collapse = ', ')}")
      cli::cli_alert_info("Sector summary available in result$sector_stats.")
    }
    return(result)
  }
  
  if (verbose && interactive()) {
    cli::cli_alert_success("Loaded {nrow(si_data)} rows from {length(csv_files)} files, {dplyr::n_distinct(si_data$sector)} sectors.")
    cli::cli_alert_info("Columns: {paste(names(si_data), collapse = ', ')}")
  }
  
  tibble::as_tibble(si_data)
}
