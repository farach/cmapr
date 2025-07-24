#' Download the CMap Career Mobility Dataset from Zenodo
#'
#' Downloads and unzips the official CMap dataset as described in Farach et al. (2025).
#' The dataset is large and not shipped with the package; this function makes reproducible access easy.
#'
#' @param dest_dir Directory to save and unzip the dataset. Defaults to tempdir().
#' @return Path to the unzipped dataset directory (usually dest_dir/dataset).
#' @details
#' The dataset is downloaded from Zenodo at https://zenodo.org/records/15260189.
#' You must run this function before using \code{load_cmap_data()}.
#' @examples
#' \dontrun{
#' dataset_dir <- download_cmap_data("~/cmap_data")
#' }
#' @importFrom utils download.file unzip
#' @export
download_cmap_data <- function(dest_dir = tempdir()) {
  url <- "https://zenodo.org/records/15260189/files/dataset.zip?download=1"
  zip_path <- file.path(dest_dir, "dataset.zip")
  utils::download.file(url, destfile = zip_path, mode = "wb")
  utils::unzip(zip_path, exdir = dest_dir)
  file.path(dest_dir, "dataset")
}