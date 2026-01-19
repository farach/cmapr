#' Find Career Paths Between Two Titles
#'
#' Discovers all promotion paths from one job title to another within a specified
#' maximum number of steps. Uses breadth-first search to find paths efficiently.
#'
#' @param edges A tibble of promotion edges (from `load_validated_promotions("edges", ...)`
#'   or `load_unvalidated_promotions("edges", ...)`).
#' @param from Character string specifying the starting job title.
#' @param to Character string specifying the target job title.
#' @param max_depth Integer specifying the maximum path length to search. Default is 5.
#' @param sector Optional character string to filter edges by sector.
#' @param ignore_case Logical; if TRUE (default), performs case-insensitive title matching.
#' @param top_n Integer specifying the maximum number of paths to return. Default is 10.
#'   Set to NULL to return all paths found.
#'
#' @return A list containing:
#' \describe{
#'   \item{paths}{A list of character vectors, each representing a path from `from` to `to`.}
#'   \item{summary}{A tibble summarizing each path with length and edge details.}
#'   \item{from}{The matched starting title.}
#'   \item{to}{The matched target title.}
#'   \item{n_paths}{Number of paths found.}
#' }
#'
#' @details
#' The function searches for all possible promotion paths between two job titles
#' in the career transition network. Paths are ordered by length (shortest first).
#'
#' Title matching is fuzzy by default - if an exact match isn't found, the function
#' will attempt to find the closest matching title.
#'
#' @examples
#' \dontrun{
#' edges <- load_validated_promotions("edges", "~/cmap_data/promotions/validated")
#'
#' # Find paths from analyst to director
#' paths <- find_career_paths(edges, from = "analyst", to = "director")
#'
#' # Filter by sector
#' paths <- find_career_paths(edges, from = "software engineer",
#'                            to = "cto", sector = "information_technology")
#' }
#'
#' @importFrom dplyr filter distinct
#' @importFrom tibble tibble
#' @export
find_career_paths <- function(edges,
                              from,
                              to,
                              max_depth = 5,
                              sector = NULL,
                              ignore_case = TRUE,
                              top_n = 10) {
  if (!is.data.frame(edges)) {
    cli::cli_abort("{.arg edges} must be a data frame or tibble.")
  }

  # Identify edge columns (different datasets use different names)
  from_col <- intersect(c("from", "title_from", "job_title_from", "source"), names(edges))[1]
  to_col <- intersect(c("to", "title_to", "job_title_to", "target"), names(edges))[1]

  if (is.na(from_col) || is.na(to_col)) {
    cli::cli_abort("Could not identify source/target columns in edges data.")
  }

  # Filter by sector if specified
  if (!is.null(sector)) {
    if ("sector" %in% names(edges)) {
      edges <- dplyr::filter(edges, .data$sector == !!sector)
    } else {
      cli::cli_warn("No 'sector' column found in edges data. Ignoring sector filter.")
    }
  }

  if (nrow(edges) == 0) {
    cli::cli_abort("No edges remaining after filtering.")
  }

  # Extract unique titles
  all_titles <- unique(c(edges[[from_col]], edges[[to_col]]))

  # Match input titles
  from_match <- match_title(from, all_titles, ignore_case)
  to_match <- match_title(to, all_titles, ignore_case)

  if (is.na(from_match)) {
    cli::cli_abort("Could not find title matching {.val {from}}. Try a different search term.")
  }
  if (is.na(to_match)) {
    cli::cli_abort("Could not find title matching {.val {to}}. Try a different search term.")
  }

  if (from_match != from && interactive()) {
    cli::cli_alert_info("Matched {.val {from}} to {.val {from_match}}")
  }
  if (to_match != to && interactive()) {
    cli::cli_alert_info("Matched {.val {to}} to {.val {to_match}}")
  }

  # Build adjacency list for BFS
  adj_list <- build_adjacency_list(edges, from_col, to_col)

  # BFS to find all paths
  paths <- bfs_find_paths(adj_list, from_match, to_match, max_depth)

  if (length(paths) == 0) {
    cli::cli_alert_warning("No paths found from {.val {from_match}} to {.val {to_match}} within {max_depth} steps.")
    return(list(
      paths = list(),
      summary = tibble::tibble(),
      from = from_match,
      to = to_match,
      n_paths = 0
    ))
  }

  # Sort by path length
  paths <- paths[order(sapply(paths, length))]

  # Limit to top_n

if (!is.null(top_n) && length(paths) > top_n) {
    paths <- paths[1:top_n]
  }

  # Create summary tibble
  summary_df <- tibble::tibble(
    path_id = seq_along(paths),
    path_length = sapply(paths, length) - 1,
    path = sapply(paths, function(p) paste(p, collapse = " -> "))
  )

  if (interactive()) {
    cli::cli_alert_success("Found {length(paths)} path(s) from {.val {from_match}} to {.val {to_match}}")
  }

  list(
    paths = paths,
    summary = summary_df,
    from = from_match,
    to = to_match,
    n_paths = length(paths)
  )
}

#' Explore Career Ladder from a Starting Title
#'
#' Discovers common career progressions from a starting job title, showing
#' the most frequent next steps and building a promotion ladder.
#'
#' @param edges A tibble of promotion edges.
#' @param start_title Character string specifying the starting job title.
#' @param depth Integer specifying how many promotion levels to explore. Default is 3.
#' @param sector Optional character string to filter edges by sector.
#' @param min_frequency Minimum edge frequency/weight to include. Default is 1.
#' @param top_n Integer specifying number of top transitions to show at each level. Default is 5.
#' @param ignore_case Logical; if TRUE (default), performs case-insensitive title matching.
#'
#' @return A list containing:
#' \describe{
#'   \item{ladder}{A tibble showing the career ladder with levels, titles, and frequencies.}
#'   \item{tree}{A nested list representation of the career progression tree.}
#'   \item{start_title}{The matched starting title.}
#' }
#'
#' @details
#' This function explores the promotion network starting from a given title,
#' identifying the most common "next step" promotions at each level. This helps
#' answer questions like "What do software engineers typically get promoted to?"
#'
#' @examples
#' \dontrun{
#' edges <- load_unvalidated_promotions("edges", "~/cmap_data/promotions/unvalidated")
#'
#' # Explore career ladder from software engineer
#' ladder <- career_ladder(edges, start_title = "software engineer", depth = 4)
#' print(ladder$ladder)
#'
#' # Filter by sector and minimum frequency
#' ladder <- career_ladder(edges, start_title = "analyst",
#'                         sector = "finance", min_frequency = 10)
#' }
#'
#' @importFrom dplyr filter arrange desc slice_head mutate bind_rows
#' @importFrom tibble tibble
#' @importFrom rlang .data
#' @export
career_ladder <- function(edges,
                          start_title,
                          depth = 3,
                          sector = NULL,
                          min_frequency = 1,
                          top_n = 5,
                          ignore_case = TRUE) {
  if (!is.data.frame(edges)) {
    cli::cli_abort("{.arg edges} must be a data frame or tibble.")
  }

  # Identify edge columns
  from_col <- intersect(c("from", "title_from", "job_title_from", "source"), names(edges))[1]
  to_col <- intersect(c("to", "title_to", "job_title_to", "target"), names(edges))[1]

  if (is.na(from_col) || is.na(to_col)) {
    cli::cli_abort("Could not identify source/target columns in edges data.")
  }

  # Identify frequency/weight column
  freq_col <- intersect(c("frequency", "weight", "count", "n"), names(edges))[1]
  if (is.na(freq_col)) {
    edges$frequency <- 1
    freq_col <- "frequency"
  }

  # Filter by sector if specified
  if (!is.null(sector)) {
    if ("sector" %in% names(edges)) {
      edges <- dplyr::filter(edges, .data$sector == !!sector)
    } else {
      cli::cli_warn("No 'sector' column found in edges data. Ignoring sector filter.")
    }
  }

  # Filter by minimum frequency
  edges <- dplyr::filter(edges, .data[[freq_col]] >= min_frequency)

  if (nrow(edges) == 0) {
    cli::cli_abort("No edges remaining after filtering.")
  }

  # Extract unique titles and match start title
  all_titles <- unique(c(edges[[from_col]], edges[[to_col]]))
  start_match <- match_title(start_title, all_titles, ignore_case)

  if (is.na(start_match)) {
    cli::cli_abort("Could not find title matching {.val {start_title}}.")
  }

  if (start_match != start_title && interactive()) {
    cli::cli_alert_info("Matched {.val {start_title}} to {.val {start_match}}")
  }

  # Build ladder level by level
  ladder_rows <- list()
  current_titles <- start_match
  visited <- character()

  for (level in seq_len(depth)) {
    # Find all outgoing edges from current titles
    level_edges <- edges |>
      dplyr::filter(.data[[from_col]] %in% current_titles) |>
      dplyr::filter(!.data[[to_col]] %in% visited)

    if (nrow(level_edges) == 0) {
      break
    }

    # Aggregate by target title
    level_summary <- level_edges |>
      dplyr::group_by(to_title = .data[[to_col]]) |>
      dplyr::summarise(
        total_frequency = sum(.data[[freq_col]], na.rm = TRUE),
        n_sources = dplyr::n_distinct(.data[[from_col]]),
        .groups = "drop"
      ) |>
      dplyr::arrange(dplyr::desc(total_frequency)) |>
      dplyr::slice_head(n = top_n) |>
      dplyr::mutate(level = level)

    ladder_rows[[level]] <- level_summary

    # Update for next iteration
    visited <- c(visited, current_titles)
    current_titles <- level_summary$to_title
  }

  if (length(ladder_rows) == 0) {
    cli::cli_alert_warning("No career progressions found from {.val {start_match}}")
    return(list(
      ladder = tibble::tibble(),
      start_title = start_match
    ))
  }

  ladder_df <- dplyr::bind_rows(ladder_rows) |>
    dplyr::select(level, title = to_title, frequency = total_frequency, n_sources)

  if (interactive()) {
    cli::cli_alert_success("Built career ladder with {nrow(ladder_df)} positions across {max(ladder_df$level)} levels")
  }

  list(
    ladder = ladder_df,
    start_title = start_match
  )
}

# -----------------------------------------------------------------------------
# Internal Helper Functions
# -----------------------------------------------------------------------------

#' Match a title string to available titles
#' @param query The search query
#' @param titles Vector of available titles
#' @param ignore_case Whether to ignore case
#' @return Matched title or NA
#' @keywords internal
match_title <- function(query, titles, ignore_case = TRUE) {
  if (ignore_case) {
    query_lower <- tolower(query)
    titles_lower <- tolower(titles)

    # Exact match first
    exact_idx <- which(titles_lower == query_lower)
    if (length(exact_idx) > 0) {
      return(titles[exact_idx[1]])
    }

    # Partial match
    partial_idx <- which(stringr::str_detect(titles_lower, stringr::fixed(query_lower)))
    if (length(partial_idx) > 0) {
      # Return shortest matching title (most specific)
      lengths <- nchar(titles[partial_idx])
      return(titles[partial_idx[which.min(lengths)]])
    }
  } else {
    # Exact match
    if (query %in% titles) {
      return(query)
    }

    # Partial match
    partial_idx <- which(stringr::str_detect(titles, stringr::fixed(query)))
    if (length(partial_idx) > 0) {
      lengths <- nchar(titles[partial_idx])
      return(titles[partial_idx[which.min(lengths)]])
    }
  }

  NA_character_
}

#' Build adjacency list from edges
#' @param edges Edge data frame
#' @param from_col Name of source column
#' @param to_col Name of target column
#' @return Named list where each element contains outgoing neighbors
#' @keywords internal
build_adjacency_list <- function(edges, from_col, to_col) {
  adj <- list()

  for (i in seq_len(nrow(edges))) {
    from_node <- edges[[from_col]][i]
    to_node <- edges[[to_col]][i]

    if (is.null(adj[[from_node]])) {
      adj[[from_node]] <- character()
    }
    adj[[from_node]] <- unique(c(adj[[from_node]], to_node))
  }

  adj
}

#' BFS to find all paths between two nodes
#' @param adj_list Adjacency list
#' @param start Start node
#' @param end End node
#' @param max_depth Maximum path length
#' @return List of paths (each path is a character vector)
#' @keywords internal
bfs_find_paths <- function(adj_list, start, end, max_depth) {
  if (start == end) {
    return(list(c(start)))
  }

  paths <- list()
  queue <- list(list(path = c(start), visited = start))

  while (length(queue) > 0) {
    current <- queue[[1]]
    queue <- queue[-1]

    current_node <- current$path[length(current$path)]
    current_path <- current$path
    current_visited <- current$visited

    # Check depth limit
    if (length(current_path) > max_depth) {
      next
    }

    # Get neighbors
    neighbors <- adj_list[[current_node]]
    if (is.null(neighbors)) {
      next
    }

    for (neighbor in neighbors) {
      if (neighbor == end) {
        # Found a path
        paths <- c(paths, list(c(current_path, neighbor)))
      } else if (!neighbor %in% current_visited && length(current_path) < max_depth) {
        # Continue exploring
        queue <- c(queue, list(list(
          path = c(current_path, neighbor),
          visited = c(current_visited, neighbor)
        )))
      }
    }
  }

  paths
}
