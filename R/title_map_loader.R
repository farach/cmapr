#' Load and Augment Job Title Mapping Data
#'
#' Reads all sector-specific CSV files from `map_dir` and combines them into a single tibble.
#' Optionally standardizes column names, filters sectors, selects columns, adds derived features,
#' and returns sector-level summary statistics.
#'
#' @param map_dir Path to the directory containing sector mapping CSV files (e.g., "~/cmap_data/titles/map").
#'   Files are expected to be named like "<sector>.csv".
#' @param columns Optional character vector of columns to keep (default: NULL = keep all).
#' @param sector_filter Optional regex pattern used to filter sectors based on the derived `sector` column
#'
#'   (default: NULL = keep all sectors).
#' @param clean Logical; if TRUE (default), standardizes column names using janitor::clean_names().
#' @param reader Character string specifying which CSV reader to use: "vroom" (default, faster) or "readr".
#' @param add_features Logical; if TRUE, adds derived variables such as title lengths and
#'   a coarse title type classifier. Default is FALSE for performance.
#' @param compute_similarity Logical; if TRUE, computes token-based Jaccard similarity between
#'   `title_cleaned` and `title_generalized`. This is expensive for large datasets. Default is FALSE.
#' @param summarize Logical; if TRUE, returns a list with `title_map` and `sector_stats`.
#' @param verbose Logical; if TRUE, emits messages (only in interactive sessions).
#'
#' @return If `summarize = FALSE`, a tibble of title mappings.
#' If `summarize = TRUE`, a list with:
#' \describe{
#'   \item{title_map}{A tibble of the combined mapping data (with optional derived features).}
#'   \item{sector_stats}{A tibble of sector/title-type summary statistics.}
#' }
#'
#' @details
#' Each CSV should contain (at minimum) title columns such as `title_cleaned` and typically
#' generalized/simplified variants (e.g., `title_generalized`, `title_simplified`) plus frequency fields.
#' If a `sector` column is not present, it is derived from the filename.
#'
#' ## Performance Notes
#' - Use `reader = "vroom"` (default) for fastest loading
#' - Set `add_features = FALSE` (default) to skip derived columns
#' - Set `compute_similarity = FALSE` (default) to skip expensive similarity computation
#' - Use `sector_filter` to load only specific sectors
#' - Use `columns` to load only needed columns
#'
#' @examples
#' \dontrun{
#' dataset_dir <- download_cmap_data("~/cmap_data")
#'
#' # Fast load - just the data (recommended for large datasets)
#' title_map <- load_title_map(file.path(dataset_dir, "titles/map"))
#'
#' # Load specific sectors only
#' tech_titles <- load_title_map(
#'   file.path(dataset_dir, "titles/map"),
#'   sector_filter = "technology|information"
#' )
#'
#' # Load with features (slower)
#' title_map <- load_title_map(
#'   file.path(dataset_dir, "titles/map"),
#'   add_features = TRUE
#' )
#'
#' # With summaries
#' res <- load_title_map(
#'   file.path(dataset_dir, "titles/map"),
#'   add_features = TRUE,
#'   summarize = TRUE
#' )
#' }
#'
#' @importFrom dplyr mutate filter select any_of group_by summarise n_distinct n arrange
#' @importFrom purrr map list_rbind
#' @importFrom tibble as_tibble tibble
#' @export
load_title_map <- function(
    map_dir,
    columns = NULL,
    sector_filter = NULL,
    clean = TRUE,
    reader = c("vroom", "readr"),
    add_features = FALSE,
    compute_similarity = FALSE,
    summarize = FALSE,
    verbose = TRUE
) {
  reader <- match.arg(reader)

  # Validate directory
validate_dir(map_dir, label = "map_dir")

  csv_files <- list.files(map_dir, pattern = "\\.csv$", full.names = TRUE)
  if (length(csv_files) == 0) {
    if (interactive()) cli::cli_warn("No CSV files found in {.path {map_dir}}")
    return(if (summarize) list(title_map = tibble::tibble(), sector_stats = tibble::tibble()) else tibble::tibble())
  }

  # --- Optimized file reading ---
  # Always read with sector derived from filename to avoid double-reading
  if (verbose && interactive()) {
    cmap_log("info", "Loading {length(csv_files)} title map files from {.path {map_dir}}")
  }

  # Choose reader function
  read_fn <- if (reader == "vroom" && requireNamespace("vroom", quietly = TRUE)) {
    \(x) vroom::vroom(x, show_col_types = FALSE, progress = FALSE)
  } else {
    if (reader == "vroom" && verbose && interactive()) {
      cmap_log("warn", "vroom not available, falling back to readr")
    }
    \(x) readr::read_csv(x, show_col_types = FALSE, progress = FALSE)
  }

  # Read all files, adding sector from filename
  title_map <- purrr::map(csv_files, \(file_path) {
    df <- read_fn(file_path)
    if (!"sector" %in% names(df)) {
      sector_name <- sub("\\.csv$", "", basename(file_path))
      df$sector <- sector_name
    }
    df
  }) |> purrr::list_rbind()

  # Standardize names
  if (clean) {
    title_map <- janitor::clean_names(title_map)
  }

  # Filter sectors EARLY (before expensive operations)
  if (!is.null(sector_filter)) {
    title_map <- dplyr::filter(title_map, stringr::str_detect(sector, sector_filter))
    if (verbose && interactive()) {
      cmap_log("info", "Filtered to {nrow(title_map)} rows matching sector pattern")
    }
  }

  # Select columns EARLY (reduce memory footprint)
  if (!is.null(columns)) {
    # Always keep sector for grouping operations
    cols_to_keep <- unique(c("sector", columns))
    title_map <- dplyr::select(title_map, dplyr::any_of(cols_to_keep))
  }

  # Derived features (opt-in for performance)
  if (add_features && "title_cleaned" %in% names(title_map)) {
    if (verbose && interactive()) {
      cmap_log("info", "Computing derived features...")
    }

    title_map <- title_map |>
      dplyr::mutate(
        title_cleaned_length = nchar(title_cleaned),
        title_word_count = stringr::str_count(title_cleaned, "\\S+"),
        title_type = classify_title_type(title_cleaned)
      )
  }

  # Similarity computation (expensive - opt-in only)
  if (compute_similarity) {
    if (all(c("title_cleaned", "title_generalized") %in% names(title_map))) {
      if (verbose && interactive()) {
        cmap_log("info", "Computing title similarity ({nrow(title_map)} rows - this may take a while)...")
      }
      title_map$title_similarity <- compute_jaccard_similarity_vectorized(
        title_map$title_cleaned,
        title_map$title_generalized
      )
    } else {
      title_map$title_similarity <- NA_real_
    }
  }

  # Convert to tibble
  title_map <- tibble::as_tibble(title_map)

  # Summarize if requested
  if (summarize) {
    sector_stats <- summarize_sector_titles(title_map, add_features, compute_similarity)

    if (verbose && interactive()) {
      cmap_log("success", "Loaded {nrow(title_map)} rows across {dplyr::n_distinct(title_map$sector)} sectors")
      if (nrow(sector_stats) > 0) {
        cmap_log("info", "Sector summary available as result$sector_stats")
      }
    }

    return(list(title_map = title_map, sector_stats = sector_stats))
  }

  if (verbose && interactive()) {
    cmap_log("success", "Loaded {nrow(title_map)} rows across {dplyr::n_distinct(title_map$sector)} sectors")
  }

  title_map
}

#' Compute Jaccard Similarity (Vectorized)
#'
#' Computes token-based Jaccard similarity between two character vectors.
#' Uses vectorized operations for better performance on large datasets.
#'
#' @param a Character vector of strings
#' @param b Character vector of strings (same length as a)
#' @return Numeric vector of Jaccard similarity scores (0-1)
#' @keywords internal
compute_jaccard_similarity_vectorized <- function(a, b) {
  n <- length(a)
  if (n == 0) return(numeric(0))

  # Pre-allocate result
  result <- rep(NA_real_, n)

  # Process in chunks to manage memory
  chunk_size <- 100000
  n_chunks <- ceiling(n / chunk_size)

  for (i in seq_len(n_chunks)) {
    start_idx <- (i - 1) * chunk_size + 1
    end_idx <- min(i * chunk_size, n)
    idx <- start_idx:end_idx

    a_chunk <- a[idx]
    b_chunk <- b[idx]

    # Identify valid pairs (both non-NA and non-empty)
    valid <- !is.na(a_chunk) & !is.na(b_chunk) & nzchar(a_chunk) & nzchar(b_chunk)

    if (any(valid)) {
      # Tokenize valid entries
      a_tokens <- strsplit(tolower(a_chunk[valid]), "\\s+")
      b_tokens <- strsplit(tolower(b_chunk[valid]), "\\s+")

      # Compute Jaccard for valid pairs
      chunk_result <- mapply(function(ta, tb) {
        ta <- ta[nzchar(ta)]
        tb <- tb[nzchar(tb)]
        if (length(ta) == 0 || length(tb) == 0) return(NA_real_)
        length(intersect(ta, tb)) / length(union(ta, tb))
      }, a_tokens, b_tokens, SIMPLIFY = TRUE, USE.NAMES = FALSE)

      result[idx[valid]] <- chunk_result
    }
  }

  result
}

#' Summarize Sector Titles
#'
#' Creates summary statistics for title data grouped by sector.
#'
#' @param df Data frame with title data
#' @param has_features Whether derived features are present
#' @param has_similarity Whether similarity was computed
#' @return Tibble with sector summary statistics
#' @keywords internal
summarize_sector_titles <- function(df, has_features = FALSE, has_similarity = FALSE) {
  if (!"sector" %in% names(df)) {
    return(tibble::tibble())
  }

  # Base grouping
  if (has_features && "title_type" %in% names(df)) {
    grouped <- dplyr::group_by(df, sector, title_type)
  } else {
    grouped <- dplyr::group_by(df, sector)
  }

  # Build summary dynamically based on available columns
  summary_df <- grouped |>
    dplyr::summarise(
      n_rows = dplyr::n(),
      n_titles = if ("title_cleaned" %in% names(df)) dplyr::n_distinct(title_cleaned) else NA_integer_,
      .groups = "drop"
    )

  # Add optional metrics if columns exist
  if (has_features && "title_cleaned_length" %in% names(df)) {
    length_stats <- df |>
      dplyr::group_by(sector) |>
      dplyr::summarise(mean_length = mean(title_cleaned_length, na.rm = TRUE), .groups = "drop")
    summary_df <- dplyr::left_join(summary_df, length_stats, by = "sector")
  }

  if (has_similarity && "title_similarity" %in% names(df)) {
    sim_stats <- df |>
      dplyr::group_by(sector) |>
      dplyr::summarise(avg_similarity = mean(title_similarity, na.rm = TRUE), .groups = "drop")
    summary_df <- dplyr::left_join(summary_df, sim_stats, by = "sector")
  }

  if ("frequency_cleaned" %in% names(df) && "title_cleaned" %in% names(df)) {
    top_titles <- df |>
      dplyr::group_by(sector) |>
      dplyr::slice_max(frequency_cleaned, n = 1, with_ties = FALSE) |>
      dplyr::select(sector, top_title = title_cleaned) |>
      dplyr::ungroup()
    summary_df <- dplyr::left_join(summary_df, top_titles, by = "sector")
  }

  summary_df |> dplyr::arrange(dplyr::desc(n_rows))
}
