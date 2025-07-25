#' Download the CMap Career Mobility Dataset from Zenodo
#'
#' Downloads and unzips the official CMap dataset as described in Subhani et al. (2025).
#' The dataset is large and not shipped with the package; this function makes reproducible access easy.
#'
#' @param dest_dir Directory to save and unzip the dataset. Defaults to tempdir().
#' @param overwrite Logical; if TRUE, always re-download even if data exists. Defaults to FALSE.
#' @return Path to the unzipped dataset directory (usually dest_dir/dataset).
#' @details
#' The dataset is downloaded from Zenodo at https://zenodo.org/records/15260189.
#' If the data is already present, the function displays a message and skips download unless overwrite = TRUE.
#' @examples
#' \dontrun{
#' dataset_dir <- download_cmap_data("~/cmap_data")
#' # To force re-download:
#' dataset_dir <- download_cmap_data("~/cmap_data", overwrite = TRUE)
#' }
#' @importFrom utils download.file unzip
#' @importFrom cli cli_alert_info cli_alert_success cli_alert_warning
#' @export
download_cmap_data <- function(dest_dir = tempdir(), overwrite = FALSE) {
  url <- "https://zenodo.org/records/15260189/files/dataset.zip?download=1"
  zip_path <- file.path(dest_dir, "dataset.zip")
  data_path <- file.path(dest_dir, "dataset")

  # Check for existing data
  has_zip <- file.exists(zip_path)
  has_dir <- dir.exists(data_path)

  if ((has_zip || has_dir) && !overwrite) {
    cli::cli_alert_info("CMap data already detected in {.file {dest_dir}}.")
    cli::cli_alert_info("Set {.code overwrite = TRUE} to re-download.")
    return(data_path)
  }

  cli::cli_alert_info("Downloading CMap dataset (~130MB) to {.file {dest_dir}} ...")
  # Set download timeout
  old_timeout <- getOption("timeout")
  options(timeout = 300)
  on.exit(options(timeout = old_timeout), add = TRUE)

  # Download and unzip
  utils::download.file(url, destfile = zip_path, mode = "wb")
  utils::unzip(zip_path, exdir = dest_dir)
  cli::cli_alert_success("Download and extraction complete.")

  return(data_path)
}
