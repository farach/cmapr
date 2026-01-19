#' Convert Promotion Edges to igraph Object
#'
#' Converts promotion edge data into an igraph directed graph object for
#' network analysis. Preserves all edge attributes from the original data.
#'
#' @param edges A tibble of promotion edges (from `load_validated_promotions("edges", ...)`
#'   or `load_unvalidated_promotions("edges", ...)`).
#' @param sector Optional character string to filter edges by sector before conversion.
#' @param directed Logical; if TRUE (default), creates a directed graph.
#' @param add_node_attrs Logical; if TRUE (default), adds node-level attributes
#'   like in-degree, out-degree, and whether the node is a source/sink.
#'
#' @return An igraph graph object with:
#' \describe{
#'   \item{vertices}{Job titles as nodes with optional degree attributes.}
#'   \item{edges}{Promotion transitions with all original attributes preserved.}
#' }
#'
#' @details
#' This function requires the igraph package to be installed. The resulting
#' graph can be analyzed using any igraph function (centrality, community
#' detection, path finding, etc.).
#'
#' Edge attributes from the original data (frequency, probability, sector, etc.)
#' are preserved and accessible via `igraph::edge_attr()`.
#'
#' @examples
#' \dontrun{
#' edges <- load_validated_promotions("edges", "~/cmap_data/promotions/validated")
#'
#' # Convert to igraph
#' g <- as_igraph(edges)
#'
#' # Basic network analysis
#' igraph::vcount(g)
#' igraph::ecount(g)
#' igraph::diameter(g)
#'
#' # Centrality analysis
#' top_central <- igraph::page_rank(g)$vector |> sort(decreasing = TRUE) |> head(10)
#'
#' # Filter by sector first
#' g_finance <- as_igraph(edges, sector = "finance")
#' }
#'
#' @seealso [as_tidygraph()] for tidygraph conversion
#' @export
as_igraph <- function(edges,
                      sector = NULL,
                      directed = TRUE,
                      add_node_attrs = TRUE) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    cli::cli_abort(c(
      "The {.pkg igraph} package is required for this function.",
      "i" = "Install it with: {.code install.packages(\"igraph\")}"
    ))
  }

  if (!is.data.frame(edges)) {
    cli::cli_abort("{.arg edges} must be a data frame or tibble.")
  }

  # Identify edge columns
  from_col <- intersect(c("from", "title_from", "job_title_from", "source"), names(edges))[1]
  to_col <- intersect(c("to", "title_to", "job_title_to", "target"), names(edges))[1]

  if (is.na(from_col) || is.na(to_col)) {
    cli::cli_abort("Could not identify source/target columns in edges data.")
  }

  # Filter by sector if specified
  if (!is.null(sector)) {
    if ("sector" %in% names(edges)) {
      edges <- edges[edges$sector == sector, ]
      if (nrow(edges) == 0) {
        cli::cli_abort("No edges found for sector {.val {sector}}.")
      }
    } else {
      cli::cli_warn("No 'sector' column found in edges data. Ignoring sector filter.")
    }
  }

  # Extract from/to vectors
  from_vec <- edges[[from_col]]
  to_vec <- edges[[to_col]]

  # Remove rows with NA values
  valid_rows <- !is.na(from_vec) & !is.na(to_vec)
  if (sum(!valid_rows) > 0 && interactive()) {
    cli::cli_alert_info("Removed {sum(!valid_rows)} edges with missing node values")
  }

  # Prepare edge list for igraph (only essential columns at first)
  edge_df <- data.frame(
    from = from_vec[valid_rows],
    to = to_vec[valid_rows],
    stringsAsFactors = FALSE
  )

  # Add other edge attributes
  other_cols <- setdiff(names(edges), c(from_col, to_col))
  for (col in other_cols) {
    edge_df[[col]] <- edges[[col]][valid_rows]
  }

  # Create unique node list
  nodes <- unique(c(edge_df$from, edge_df$to))
  node_df <- data.frame(name = nodes, stringsAsFactors = FALSE)

  # Create igraph object
  g <- igraph::graph_from_data_frame(
    d = edge_df,
    directed = directed,
    vertices = node_df
  )

  # Add node attributes if requested
  if (add_node_attrs) {
    igraph::V(g)$in_degree <- igraph::degree(g, mode = "in")
    igraph::V(g)$out_degree <- igraph::degree(g, mode = "out")
    igraph::V(g)$is_source <- igraph::V(g)$in_degree == 0 & igraph::V(g)$out_degree > 0
    igraph::V(g)$is_sink <- igraph::V(g)$out_degree == 0 & igraph::V(g)$in_degree > 0
  }

  if (interactive()) {
    cli::cli_alert_success(
      "Created igraph with {igraph::vcount(g)} nodes and {igraph::ecount(g)} edges"
    )
  }

  g
}

#' Convert Promotion Edges to tidygraph Object
#'
#' Converts promotion edge data into a tidygraph object for tidy network analysis.
#' This allows using dplyr verbs directly on graph data.
#'
#' @param edges A tibble of promotion edges (from `load_validated_promotions("edges", ...)`
#'   or `load_unvalidated_promotions("edges", ...)`).
#' @param sector Optional character string to filter edges by sector before conversion.
#' @param directed Logical; if TRUE (default), creates a directed graph.
#' @param add_node_attrs Logical; if TRUE (default), adds node-level attributes.
#'
#' @return A tidygraph `tbl_graph` object that can be manipulated with dplyr verbs
#'   and visualized with ggraph.
#'
#' @details
#' This function requires the tidygraph package to be installed. The tidygraph
#' framework allows you to use familiar dplyr verbs (`filter`, `mutate`, `select`, etc.)
#' on both nodes and edges of the graph.
#'
#' Use `activate(nodes)` or `activate(edges)` to switch between manipulating
#' nodes and edges.
#'
#' @examples
#' \dontrun{
#' edges <- load_unvalidated_promotions("edges", "~/cmap_data/promotions/unvalidated")
#'
#' # Convert to tidygraph
#' g <- as_tidygraph(edges)
#'
#' # Tidy network analysis
#' library(tidygraph)
#' library(dplyr)
#'
#' # Find most central titles
#' g |>
#'   activate(nodes) |>
#'   mutate(centrality = centrality_pagerank()) |>
#'   arrange(desc(centrality)) |>
#'   as_tibble() |>
#'   head(10)
#'
#' # Filter edges by frequency
#' g |>
#'   activate(edges) |>
#'   filter(frequency > 100)
#'
#' # Visualize with ggraph
#' library(ggraph)
#' g |>
#'   activate(nodes) |>
#'   mutate(centrality = centrality_pagerank()) |>
#'   filter(centrality > 0.001) |>
#'   ggraph(layout = "fr") +
#'   geom_edge_link(alpha = 0.2) +
#'   geom_node_point(aes(size = centrality)) +
#'   geom_node_text(aes(label = name), repel = TRUE, size = 2)
#' }
#'
#' @seealso [as_igraph()] for igraph conversion
#' @export
as_tidygraph <- function(edges,
                         sector = NULL,
                         directed = TRUE,
                         add_node_attrs = TRUE) {
  if (!requireNamespace("tidygraph", quietly = TRUE)) {
    cli::cli_abort(c(
      "The {.pkg tidygraph} package is required for this function.",
      "i" = "Install it with: {.code install.packages(\"tidygraph\")}"
    ))
  }

  # First convert to igraph, then to tidygraph
  g <- as_igraph(
    edges = edges,
    sector = sector,
    directed = directed,
    add_node_attrs = add_node_attrs
  )

  # Convert to tidygraph
 tg <- tidygraph::as_tbl_graph(g)

  if (interactive()) {
    cli::cli_alert_info("Use {.code activate(nodes)} or {.code activate(edges)} to switch contexts")
  }

  tg
}

#' Get Network Summary Statistics
#'
#' Calculates common network metrics for a promotion graph.
#'
#' @param edges A tibble of promotion edges, or an igraph/tidygraph object.
#' @param sector Optional character string to filter by sector (only used if edges is a tibble).
#'
#' @return A tibble with network summary statistics including:
#' \describe{
#'   \item{n_nodes}{Number of unique job titles (nodes).}
#'   \item{n_edges}{Number of promotion transitions (edges).}
#'   \item{density}{Graph density (proportion of possible edges that exist).}
#'   \item{avg_in_degree}{Average number of incoming promotions per title.}
#'   \item{avg_out_degree}{Average number of outgoing promotions per title.}
#'   \item{n_components}{Number of weakly connected components.}
#'   \item{largest_component_size}{Size of the largest connected component.}
#'   \item{diameter}{Diameter of the largest component (longest shortest path).}
#' }
#'
#' @examples
#' \dontrun{
#' edges <- load_validated_promotions("edges", "~/cmap_data/promotions/validated")
#' stats <- network_summary(edges)
#' print(stats)
#'
#' # By sector
#' stats_finance <- network_summary(edges, sector = "finance")
#' }
#'
#' @importFrom tibble tibble
#' @export
network_summary <- function(edges, sector = NULL) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    cli::cli_abort(c(
      "The {.pkg igraph} package is required for this function.",
      "i" = "Install it with: {.code install.packages(\"igraph\")}"
    ))
  }

  # Convert to igraph if needed
  if (inherits(edges, "igraph")) {
    g <- edges
  } else if (inherits(edges, "tbl_graph")) {
    g <- edges
  } else {
    g <- as_igraph(edges, sector = sector, add_node_attrs = FALSE)
  }

  # Calculate metrics
  n_nodes <- igraph::vcount(g)
  n_edges <- igraph::ecount(g)
  density <- igraph::edge_density(g)

  in_deg <- igraph::degree(g, mode = "in")
  out_deg <- igraph::degree(g, mode = "out")

  components <- igraph::components(g, mode = "weak")
  n_components <- components$no
  largest_component_size <- max(components$csize)

  # Diameter (on largest component to avoid Inf)
  if (n_components == 1) {
    diameter <- igraph::diameter(g, directed = TRUE)
  } else {
    largest_comp_ids <- which(components$membership == which.max(components$csize))
    subg <- igraph::induced_subgraph(g, largest_comp_ids)
    diameter <- igraph::diameter(subg, directed = TRUE)
  }

  tibble::tibble(
    n_nodes = n_nodes,
    n_edges = n_edges,
    density = round(density, 6),
    avg_in_degree = round(mean(in_deg), 2),
    avg_out_degree = round(mean(out_deg), 2),
    max_in_degree = max(in_deg),
    max_out_degree = max(out_deg),
    n_components = n_components,
    largest_component_size = largest_component_size,
    largest_component_pct = round(100 * largest_component_size / n_nodes, 1),
    diameter = diameter
  )
}
