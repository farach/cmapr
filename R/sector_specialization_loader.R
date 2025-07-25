#' Load Sector-Specific Title Specialization Data
#'
#' Reads all sector-specific CSV files from the `titles/si` folder and combines them into a single tidy dataframe.
#' Each file provides job title frequencies and specialization metrics for one industry sector.
#'
#' @param si_dir Path to the directory containing sector CSV files (e.g., "~/cmap_data/titles/si").
#' @return A tibble with columns: sector, title, frequency, weighted_frequency, SE, SD, SI, onet_soc_codes.
#' @details
#' Each file in `si_dir` must be named `<sector>.csv` and include columns:
#' sector, title, frequency, weighted_frequency, SE, SD, SI, onet_soc_codes.
#' See accompanying paper for metric methodology.
#' @examples
#' si_data <- load_sector_specialization("~/cmap_data/dataset/titles/si")
#' head(si_data)
#' @importFrom purrr map_dfr
#' @importFrom readr read_csv
#' @importFrom dplyr mutate
#' @export
load_sector_specialization <- function(si_dir) {
  # Find all CSV files in the directory
  csv_files <- list.files(si_dir, pattern = "\\.csv$", full.names = TRUE)

  # Read and combine all sector CSVs
  si_data <- purrr::map_dfr(csv_files, ~ {
    df <- readr::read_csv(.x, show_col_types = FALSE)
    # Add sector from filename if missing
    if (!"sector" %in% names(df)) {
      sector_name <- basename(.x) |> sub("\\.csv$", "", .)
      df <- dplyr::mutate(df, sector = sector_name)
    }
    df
  })

  # Standardize column names (if needed)
  names(si_data) <- names(si_data) |>
    stringr::str_replace_all(" ", "_") |>
    tolower()

  # Return as tibble
  dplyr::as_tibble(si_data)
}
