#' Load Unvalidated Promotions Data
#'
#' Loads statistically inferred promotion data from the specified folder containing region/sector-specific job movement CSVs.
#' Supports loading "edges" (job movements with inference metrics) and "nodes" (title frequencies per region/sector).
#' Optionally lists and opens sector-region network .html files for interactive visualization.
#'
#' @param subfolder Which subfolder to load: "edges", "nodes", or "network".
#' @param data_dir Path to root unvalidated promotions directory (e.g., "~/cmap_data/dataset/promotions/unvalidated").
#' @param open_html Optional: name of .html file to open from the network folder (e.g., "EUROPE_finance.html").
#' @return For "edges" or "nodes": dataframe (tibble) with unvalidated promotion data. For "network": list of available HTML files (invisible if opening one).
#' @details
#' Edges: Promotion movements with inference metrics (EPS, JSS, EPDR, promotion_prob).
#' Nodes: Job title frequencies by region/sector.
#' Network: Interactive HTML sector-region visualization files.
#' See README in the dataset for column details and methodology.
#' @examples
#' # Load all unvalidated promotion edges (job movements)
#' unvalidated_edges <- load_unvalidated_promotions("edges", "~/cmap_data/dataset/promotions/unvalidated")
#' # Load all unvalidated title nodes
#' unvalidated_nodes <- load_unvalidated_promotions("nodes", "~/cmap_data/dataset/promotions/unvalidated")
#' # List available network HTML files
#' unvalidated_networks <- load_unvalidated_promotions("network", "~/cmap_data/dataset/promotions/unvalidated")
#' # Open a specific sector-region network visualization
#' load_unvalidated_promotions("network", "~/cmap_data/dataset/promotions/unvalidated", open_html = "EUROPE_finance.html")
#' @importFrom purrr map_dfr
#' @importFrom readr read_csv
#' @importFrom utils browseURL
#' @export
load_unvalidated_promotions <- function(subfolder = c("edges", "nodes", "network"),
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
