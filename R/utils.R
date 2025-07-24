#' Helper: List all CSV files recursively
#' @param dir_path Path to directory
#' @return Character vector of file paths
find_csv_files <- function(dir_path) {
  list.files(dir_path, pattern = "\\.csv$", full.names = TRUE, recursive = TRUE)
}