#' Summarize Career Transitions
#'
#' Aggregates transition counts and weights by specified grouping variables.
#'
#' @param model_data A tibble containing career transition data (e.g., from load_cmap_data()).
#' @param by Character vector specifying grouping variables. Default is c("sector", "region").
#' @param weight Character string specifying the weight column to sum. Default is "transition_weighted_count".
#' @return A tibble with grouped transition summaries including total transitions and total weighted transitions.
#' @details
#' This function groups the model_data by the specified variables and calculates:
#' - n_transitions: count of transitions
#' - total_weight: sum of the weight column
#' @examples
#' \dontrun{
#' result <- load_cmap_data(base_path = "~/cmap_data")
#' summary <- summarize_transitions(result$model_data, by = c("sector", "region"))
#' }
#' @importFrom dplyr group_by summarise n
#' @importFrom rlang .data
#' @export
summarize_transitions <- function(model_data, 
                                   by = c("sector", "region"), 
                                   weight = "transition_weighted_count") {
  if (!is.data.frame(model_data)) {
    cli::cli_abort("{.arg model_data} must be a data frame or tibble.")
  }
  
  if (!all(by %in% names(model_data))) {
    missing <- setdiff(by, names(model_data))
    cli::cli_abort("Grouping variable(s) not found in model_data: {.val {missing}}")
  }
  
  if (!weight %in% names(model_data)) {
    cli::cli_abort("Weight column {.val {weight}} not found in model_data.")
  }
  
  model_data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(by))) |>
    dplyr::summarise(
      n_transitions = dplyr::n(),
      total_weight = sum(.data[[weight]], na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::arrange(dplyr::desc(total_weight))
}

#' Top Career Transitions
#'
#' Returns the top N transitions by weight within each group.
#'
#' @param model_data A tibble containing career transition data (e.g., from load_cmap_data()).
#' @param by Character vector specifying grouping variables. Default is c("sector", "region").
#' @param n Integer specifying the number of top transitions to return per group. Default is 10.
#' @param weight Character string specifying the weight column to rank by. Default is "transition_weighted_count".
#' @return A tibble with the top N transitions per group, ranked by weight.
#' @details
#' This function groups the model_data by the specified variables and returns the top N rows
#' (ranked by the weight column) for each group.
#' @examples
#' \dontrun{
#' result <- load_cmap_data(base_path = "~/cmap_data")
#' top <- top_transitions(result$model_data, by = "sector", n = 5)
#' }
#' @importFrom dplyr group_by slice_max ungroup
#' @importFrom rlang .data
#' @export
top_transitions <- function(model_data, 
                            by = c("sector", "region"), 
                            n = 10, 
                            weight = "transition_weighted_count") {
  if (!is.data.frame(model_data)) {
    cli::cli_abort("{.arg model_data} must be a data frame or tibble.")
  }
  
  if (!all(by %in% names(model_data))) {
    missing <- setdiff(by, names(model_data))
    cli::cli_abort("Grouping variable(s) not found in model_data: {.val {missing}}")
  }
  
  if (!weight %in% names(model_data)) {
    cli::cli_abort("Weight column {.val {weight}} not found in model_data.")
  }
  
  model_data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(by))) |>
    dplyr::slice_max(order_by = .data[[weight]], n = n, with_ties = FALSE) |>
    dplyr::ungroup()
}

#' Calculate Promotion Rate
#'
#' Calculates promotion rates from validated promotions data.
#'
#' @param validated_promotions A tibble containing validated promotion data 
#'   (e.g., from load_validated_promotions("edges", ...)).
#' @param by Character vector specifying grouping variables. Default is c("sector", "region").
#' @return A tibble with promotion rates by group.
#' @details
#' This function calculates the promotion rate as the mean of a binary promotion indicator.
#' The data is expected to have columns for grouping (sector, region, etc.).
#' If a 'promoted' or 'is_promotion' column exists, it will be used; otherwise,
#' the function will calculate based on available metrics.
#' @examples
#' \dontrun{
#' validated <- load_validated_promotions("edges", "~/cmap_data/promotions/validated")
#' rates <- promotion_rate(validated, by = c("sector", "region"))
#' }
#' @importFrom dplyr group_by summarise n
#' @importFrom rlang .data
#' @export
promotion_rate <- function(validated_promotions, 
                           by = c("sector", "region")) {
  if (!is.data.frame(validated_promotions)) {
    cli::cli_abort("{.arg validated_promotions} must be a data frame or tibble.")
  }
  
  if (!all(by %in% names(validated_promotions))) {
    missing <- setdiff(by, names(validated_promotions))
    cli::cli_abort("Grouping variable(s) not found in validated_promotions: {.val {missing}}")
  }
  
  # Try to identify promotion indicator column
  promo_col <- NULL
  if ("promoted" %in% names(validated_promotions)) {
    promo_col <- "promoted"
  } else if ("is_promotion" %in% names(validated_promotions)) {
    promo_col <- "is_promotion"
  } else if ("promotion" %in% names(validated_promotions)) {
    promo_col <- "promotion"
  }
  
  if (is.null(promo_col)) {
    # If no promotion column, assume all edges are promotions
    validated_promotions |>
      dplyr::group_by(dplyr::across(dplyr::all_of(by))) |>
      dplyr::summarise(
        n_promotions = dplyr::n(),
        promotion_rate = 1.0,
        .groups = "drop"
      )
  } else {
    validated_promotions |>
      dplyr::group_by(dplyr::across(dplyr::all_of(by))) |>
      dplyr::summarise(
        n_total = dplyr::n(),
        n_promotions = sum(.data[[promo_col]], na.rm = TRUE),
        promotion_rate = mean(.data[[promo_col]], na.rm = TRUE),
        .groups = "drop"
      )
  }
}

#' Generate Sector Profile
#'
#' Creates a profile summary for each sector showing key transition metrics.
#'
#' @param model_data A tibble containing career transition data (e.g., from load_cmap_data()).
#' @param by Character string specifying the grouping variable. Default is "sector".
#' @param weight Character string specifying the weight column. Default is "transition_weighted_count".
#' @return A tibble with sector profiles including total transitions, unique job titles, and average metrics.
#' @details
#' This function creates a comprehensive sector profile including:
#' - Total number of transitions
#' - Total weighted transitions
#' - Number of unique job titles (from and to)
#' - Average specialization indices if available
#' @examples
#' \dontrun{
#' result <- load_cmap_data(base_path = "~/cmap_data")
#' profile <- sector_profile(result$model_data, by = "sector")
#' }
#' @importFrom dplyr group_by summarise n_distinct
#' @importFrom rlang .data
#' @export
sector_profile <- function(model_data, 
                           by = "sector", 
                           weight = "transition_weighted_count") {
  if (!is.data.frame(model_data)) {
    cli::cli_abort("{.arg model_data} must be a data frame or tibble.")
  }
  
  if (!by %in% names(model_data)) {
    cli::cli_abort("Grouping variable {.val {by}} not found in model_data.")
  }
  
  if (!weight %in% names(model_data)) {
    cli::cli_abort("Weight column {.val {weight}} not found in model_data.")
  }
  
  summary <- model_data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(by))) |>
    dplyr::summarise(
      n_transitions = dplyr::n(),
      total_weight = sum(.data[[weight]], na.rm = TRUE),
      unique_titles_from = dplyr::n_distinct(.data$job_title_from, na.rm = TRUE),
      unique_titles_to = dplyr::n_distinct(.data$job_title_to, na.rm = TRUE),
      .groups = "drop"
    )

  # Add optional specialization metrics if available
  if ("si_from" %in% names(model_data)) {
    summary <- summary |>
      dplyr::left_join(
        model_data |>
          dplyr::group_by(dplyr::across(dplyr::all_of(by))) |>
          dplyr::summarise(
            avg_si_from = mean(.data$si_from, na.rm = TRUE),
            avg_si_to = mean(.data$si_to, na.rm = TRUE),
            .groups = "drop"
          ),
        by = by
      )
  }

  summary |>
    dplyr::arrange(dplyr::desc(total_weight))
}

#' Calculate Title Frequency
#'
#' Summarizes the most frequent job titles from the title mapping data.
#'
#' @param title_map A tibble containing title mapping data (e.g., from load_title_map()).
#' @param by Character vector specifying grouping variables. Default is c("sector", "region").
#' @param n Integer specifying the number of top titles to return per group. Default is 10.
#' @return A tibble with the top N most frequent titles per group.
#' @details
#' This function identifies frequency columns in the title map data and returns
#' the top N titles by frequency within each group. It looks for columns like
#' 'frequency', 'frequency_simplified', or 'weighted_frequency'.
#' @examples
#' \dontrun{
#' title_map <- load_title_map("~/cmap_data/titles/map")
#' freq <- title_frequency(title_map, by = "sector", n = 20)
#' }
#' @importFrom dplyr group_by slice_max ungroup
#' @importFrom rlang .data
#' @export
title_frequency <- function(title_map, 
                            by = c("sector", "region"), 
                            n = 10) {
  if (!is.data.frame(title_map)) {
    cli::cli_abort("{.arg title_map} must be a data frame or tibble.")
  }
  
  # Filter by to only existing columns
  by_existing <- by[by %in% names(title_map)]
  
  if (length(by_existing) == 0) {
    cli::cli_abort("None of the grouping variables {.val {by}} found in title_map.")
  }
  
  if (length(by_existing) < length(by)) {
    missing <- setdiff(by, by_existing)
    cli::cli_warn("Some grouping variables not found and will be ignored: {.val {missing}}")
  }
  
  # Identify frequency column
  freq_col <- NULL
  if ("frequency_simplified" %in% names(title_map)) {
    freq_col <- "frequency_simplified"
  } else if ("weighted_frequency" %in% names(title_map)) {
    freq_col <- "weighted_frequency"
  } else if ("frequency" %in% names(title_map)) {
    freq_col <- "frequency"
  } else if ("frequency_cleaned" %in% names(title_map)) {
    freq_col <- "frequency_cleaned"
  }
  
  if (is.null(freq_col)) {
    cli::cli_abort("No frequency column found in title_map. Expected columns like 'frequency', 'frequency_simplified', or 'weighted_frequency'.")
  }
  
  title_map |>
    dplyr::group_by(dplyr::across(dplyr::all_of(by_existing))) |>
    dplyr::slice_max(order_by = .data[[freq_col]], n = n, with_ties = FALSE) |>
    dplyr::ungroup()
}
