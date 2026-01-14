#' Load Job Title Mapping Data
#'
#' Reads all sector-specific CSV files from the `dataset/titles/map` folder and combines them into one tidy dataframe.
#' Each file traces job titles through the standardization pipeline: cleaning, generalization, and simplification.
#'
#' @param map_dir Path to the directory containing sector mapping CSV files (e.g., "~/cmap_data/dataset/titles/map").
#' @param clean Logical; if TRUE (default), standardizes column names using janitor::clean_names().
#' @param reader Character string specifying which CSV reader to use: "readr" (default) or "vroom".
#' @return A tibble with columns: sector, title_cleaned, frequency_cleaned, title_generalized, frequency_generalized, title_simplified, frequency_simplified.
#' @details
#' Each file in `map_dir` should be named <sector>.csv and provide columns as described above.
#' See the accompanying publication for methodology.
#' @examples
#' title_map <- load_title_map("~/cmap_data/dataset/titles/map")
#' dplyr::glimpse(title_map)
#' @importFrom dplyr mutate
#' @export
load_title_map <- function(map_dir, clean = TRUE, reader = c("readr", "vroom")) {
  reader <- match.arg(reader)
  validate_dir(map_dir, label = "map_dir")
  
  csv_files <- list.files(map_dir, pattern = "\\.csv$", full.names = TRUE)
  
  if (length(csv_files) == 0) {
    cli::cli_warn("No CSV files found in {.path {map_dir}}")
    return(tibble::tibble())
  }

  title_map <- read_csvs(csv_files, reader = reader)
  
  # Add sector from filename if missing
  if (!"sector" %in% names(title_map)) {
    # Re-read with sector info
    title_map <- purrr::map_dfr(csv_files, ~ {
      df <- if (reader == "vroom") {
        vroom::vroom(.x, show_col_types = FALSE)
      } else {
        readr::read_csv(.x, show_col_types = FALSE)
      }
      sector_name <- basename(.x) |> sub("\\.csv$", "", .)
      dplyr::mutate(df, sector = sector_name)
    })
  }

  title_map <- normalize_names(title_map, clean = clean)
  
  dplyr::as_tibble(title_map)
}
