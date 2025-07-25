#' Load Job Title Mapping Data
#'
#' Reads all sector-specific CSV files from the `dataset/titles/map` folder and combines them into one tidy dataframe.
#' Each file traces job titles through the standardization pipeline: cleaning, generalization, and simplification.
#'
#' @param map_dir Path to the directory containing sector mapping CSV files (e.g., "~/cmap_data/dataset/titles/map").
#' @return A tibble with columns: sector, title_cleaned, frequency_cleaned, title_generalized, frequency_generalized, title_simplified, frequency_simplified.
#' @details
#' Each file in `map_dir` should be named <sector>.csv and provide columns as described above.
#' See the accompanying publication for methodology.
#' @examples
#' title_map <- load_title_map("~/cmap_data/dataset/titles/map")
#' dplyr::glimpse(title_map)
#' @importFrom purrr map_dfr
#' @importFrom readr read_csv
#' @importFrom dplyr mutate
#' @export
load_title_map <- function(map_dir) {
  csv_files <- list.files(map_dir, pattern = "\\.csv$", full.names = TRUE)
  
  title_map <- purrr::map_dfr(csv_files, ~{
    df <- readr::read_csv(.x, show_col_types = FALSE)
    # Add sector from filename if missing
    if (!"sector" %in% names(df)) {
      sector_name <- basename(.x) |> sub("\\.csv$", "", .)
      df <- dplyr::mutate(df, sector = sector_name)
    }
    df
  })
  
  # Standardize column names (if needed)
  names(title_map) <- names(title_map) |> 
    stringr::str_replace_all(" ", "_") |> 
    tolower()
  
  dplyr::as_tibble(title_map)
}