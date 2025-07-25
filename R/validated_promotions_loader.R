#' Load Validated Promotions Data
#'
#' Loads validated promotion data from the specified folder containing sector/country-specific job movement CSVs.
#' Supports loading "edges" (job movements with validation metrics) and "nodes" (title frequencies per sector/country).
#' Optionally lists and opens sector/country network .html files for interactive visualization.
#'
#' @param subfolder Which subfolder to load: "edges", "nodes", or "network".
#' @param data_dir Path to root validated promotions directory (e.g., "~/cmap_data/dataset/promotions/validated").
#' @param open_html Optional: name of .html file to open from the network folder (e.g., "US_accounting_and_legal.html").
#' @return For "edges" or "nodes": dataframe (tibble) with validated promotion data. For "network": list of available HTML files (invisible if opening one).
#' @details
#' Edges: Promotion movements with validation metrics.
#' Nodes: Job title frequencies by sector/country.
#' Network: Interactive HTML sector/country visualization files.
#' See README in the dataset for column details and methodology.
#' @examples
#' # Load all validated promotion edges (job movements)
#' validated_edges <- load_validated_promotions("edges", "~/cmap_data/dataset/promotions/validated")
#' # Load all validated title nodes
#' validated_nodes <- load_validated_promotions("nodes", "~/cmap_data/dataset/promotions/validated")
#' # List available network HTML files
#' validated_networks <- load_validated_promotions("network", "~/cmap_data/dataset/promotions/validated")
#' # Open a specific sector/country network visualization
#' load_validated_promotions("network", "~/cmap_data/dataset/promotions/validated", open_html = "US_accounting_and_legal.html")
#' @importFrom purrr map_dfr
#' @importFrom readr read_csv
#' @importFrom utils browseURL
#' @export
load_validated_promotions <- function(subfolder = c("edges", "nodes", "network"),
                                      data_dir,
                                      open_html = NULL) {
  subfolder <- match.arg(subfolder)
  target_dir <- file.path(data_dir, subfolder)

  if (!dir.exists(target_dir)) {
    stop("Target subfolder does not exist: ", target_dir)
  }

  if (subfolder %in% c("edges", "nodes")) {
    # Load all CSV files except system/hidden files
    csv_files <- list.files(target_dir, pattern = "^[A-Z]+_.*\\.csv$", full.names = TRUE)
    promotions_data <- purrr::map_dfr(csv_files, ~ readr::read_csv(.x, show_col_types = FALSE))
    return(dplyr::as_tibble(promotions_data))
  }

  if (subfolder == "network") {
    html_files <- list.files(target_dir, pattern = "\\.html$", full.names = FALSE)
    if (!is.null(open_html)) {
      html_path <- file.path(target_dir, open_html)
      if (!file.exists(html_path)) stop("HTML file not found: ", html_path)
      utils::browseURL(html_path)
      invisible(html_path)
    } else {
      return(html_files)
    }
  }
}
