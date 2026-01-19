#' Get Path to Example Data
#'
#' Returns the path to example data files included with the cmapr package.
#'
#' @param file Character string specifying the example file name.
#'   Default is "example_transitions.csv".
#' @return Character string containing the full path to the example file,
#'   or an empty string if the file does not exist.
#' @examples
#' # Get path to example transitions data
#' example_path <- cmap_example_data()
#' if (nzchar(example_path)) {
#'   head(readr::read_csv(example_path))
#' }
#' @export
cmap_example_data <- function(file = "example_transitions.csv") {

  system.file("extdata", file, package = "cmapr", mustWork = FALSE)
}
