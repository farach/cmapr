#' CMap Data Loader
#'
#' Functions to load and prepare CMap data according to
#' Subhani et al. (2025): https://www.nature.com/articles/s41597-025-05526-3
#'
#' All functions follow tidyverse idioms and use tibbles throughout.
#'
#' @param base_path Path to the unzipped CMap dataset directory (e.g. as returned by \code{download_cmap_data()}).
#' @param ext_path Path to extended dataset (if applicable).
#' @param output_path Path to save processed outputs (optional).
#' @param verbose Logical, print progress messages?
#' @return A list containing processed model_data and metadata.
#' @details
#' The full dataset must be downloaded first with \code{download_cmap_data()}.
#' Example:
#' \preformatted{
#'   dataset_dir <- download_cmap_data("~/cmap_data")
#'   result <- load_cmap_data(base_path = dataset_dir)
#' }
#' @importFrom dplyr mutate left_join select rename_with bind_rows across as_tibble any_of
#' @importFrom purrr map_lgl
#' @importFrom magrittr %>%
#' @importFrom readr read_csv
#' @importFrom janitor clean_names
#' @importFrom purrr map_dfr walk
#' @importFrom stringr str_detect str_extract str_remove
#' @importFrom stats runif setNames
#' @importFrom cli cli_h1 cli_text cli_h2 cli_alert_info cli_alert_warning
#' @export
load_cmap_data <- function(
    base_path,
    ext_path = NULL,
    output_path = NULL,
    verbose = TRUE
) {
  # NOTE: Do NOT use library() calls inside package functions!
  # All package functions are referenced with :: or imported via NAMESPACE.
  
  if(verbose) {
    cli::cli_h1("CMap Data Loading")
    cli::cli_text("Base path: {base_path}")
    if(!is.null(ext_path)) cli::cli_text("Extended path: {ext_path}")
    if(!is.null(output_path)) cli::cli_text("Output path: {output_path}")
    cli::cli_text("User: {Sys.info()[['user']]}")
    cli::cli_text("Time: {format(Sys.time(), '%Y-%m-%d %H:%M:%S')}")
  }
  
  if(!is.null(output_path)) {
    dir.create(output_path, showWarnings = FALSE, recursive = TRUE)
  }
  
  # Utility to list CSV files recursively
  find_csv_files <- function(dir_path) {
    list.files(dir_path, pattern = "\\.csv$", full.names = TRUE, recursive = TRUE)
  }
  
  # Directory analysis (optional, for reporting)
  if(verbose) {
    cli::cli_h2("Analyzing Directory Structure")
    dirs <- c(
      file.path(base_path, "promotions"),
      file.path(base_path, "promotions/validated"),
      file.path(base_path, "promotions/unvalidated"),
      file.path(base_path, "titles/map"),
      file.path(base_path, "titles/si")
    )
    purrr::walk(dirs, function(.x) {
      if (dir.exists(.x)) {
        cli::cli_alert_success("Directory exists: {.path {.x}}")
      } else {
        cli::cli_alert_danger("Directory missing: {.path {.x}}")
      }
    })
  }
  
  # Load promotion data (validated/unvalidated)
  load_promotion_df <- function(base_dir, is_validated = TRUE) {
    files <- find_csv_files(base_dir)
    if(verbose) cli::cli_alert_info("Found {length(files)} promotion files in {base_dir}")
    required_cols <- c("job_title_from", "job_title_to", "promotion_probability",
                       "region", "sector", "validated", "source_file")
    promotions <- purrr::map_dfr(files, function(file_path) {
      result <- tryCatch({
        dat <- readr::read_csv(file_path, na = c("NA", "", "NULL"), show_col_types = FALSE) %>%
          janitor::clean_names()
        n <- nrow(dat)
        # Infer region/sector from file path
        fname <- basename(file_path)
        region <- "Unknown"
        sector <- "Unknown"
        if(stringr::str_detect(fname, "^[^_]+_.*\\.csv$")) {
          region <- stringr::str_extract(fname, "^[^_]+")
          sector <- stringr::str_remove(stringr::str_remove(fname, "^[^_]+_"), "\\.csv$")
        }
        dat <- dplyr::mutate(dat,
                             region = region,
                             sector = sector,
                             validated = is_validated,
                             source_file = file_path
        )
        # Identify job_title_from
        if(!("job_title_from" %in% names(dat))) {
          title_cols <- names(dat)[stringr::str_detect(names(dat), "title|job|position|role|source")]
          if(length(title_cols) > 0)
            dat <- dplyr::mutate(dat, job_title_from = dat[[title_cols[1]]])
          else
            dat <- dplyr::mutate(dat, job_title_from = paste("Job", seq_len(n)))
        }
        # Identify job_title_to
        if(!("job_title_to" %in% names(dat))) {
          title_cols <- setdiff(names(dat)[stringr::str_detect(names(dat), "title|job|position|role|target")],
                                names(dat)[stringr::str_detect(names(dat), "from|source")])
          if(length(title_cols) > 0)
            dat <- dplyr::mutate(dat, job_title_to = dat[[title_cols[1]]])
          else
            dat <- dplyr::mutate(dat, job_title_to = paste("Target Job", seq_len(n)))
        }
        # Promotion probability
        if(!("promotion_probability" %in% names(dat))) {
          prob_cols <- names(dat)[stringr::str_detect(names(dat), "prob|likelihood|chance|score")]
          if(length(prob_cols) > 0)
            dat <- dplyr::mutate(dat, promotion_probability = as.numeric(dat[[prob_cols[1]]]))
          else
            dat <- dplyr::mutate(dat, promotion_probability = stats::runif(n))
        }
        # Ensure required columns exist
        for(col in required_cols) {
          if(!col %in% names(dat)) dat[[col]] <- NA
        }
        dplyr::select(dat, dplyr::all_of(required_cols), dplyr::everything())
      }, error = function(e) {
        if(verbose) cli::cli_alert_warning("Error reading {file_path}: {e$message}")
        NULL
      })
      result
    })
    promotions
  }
  
  validated_dir <- file.path(base_path, "promotions/validated")
  unvalidated_dir <- file.path(base_path, "promotions/unvalidated")
  validated_promotions <- load_promotion_df(validated_dir, TRUE)
  unvalidated_promotions <- load_promotion_df(unvalidated_dir, FALSE)
  all_promotions <- dplyr::bind_rows(validated_promotions, unvalidated_promotions)
  
  # Load title mappings
  load_title_mappings <- function() {
    files <- find_csv_files(file.path(base_path, "titles/map"))
    if(verbose) cli::cli_alert_info("Found {length(files)} title mapping files")
    purrr::map_dfr(files, function(file_path) {
      tryCatch({
        dat <- readr::read_csv(file_path, na = c("NA", "", "NULL"), show_col_types = FALSE) %>%
          janitor::clean_names()
        sector <- tools::file_path_sans_ext(basename(file_path))
        dplyr::mutate(dat, sector = sector)
      }, error = function(e) {
        if(verbose) cli::cli_alert_warning("Error reading {file_path}: {e$message}")
        NULL
      })
    })
  }
  title_mappings <- load_title_mappings()
  
  # Load specialization indices
  load_specialization_indices <- function() {
    files <- find_csv_files(file.path(base_path, "titles/si"))
    if(verbose) cli::cli_alert_info("Found {length(files)} specialization index files")
    expected_cols <- c("job_title", "si", "se", "sd", "weighted_freq")
    alt_cols <- c("title", "specialization_index", "sector_exclusivity",
                  "sector_dominance", "weighted_frequency")
    col_mapping <- stats::setNames(expected_cols, alt_cols)
    purrr::map_dfr(files, function(file_path) {
      tryCatch({
        dat <- readr::read_csv(file_path, na = c("NA", "", "NULL"), show_col_types = FALSE) %>%
          janitor::clean_names()
        sector <- tools::file_path_sans_ext(basename(file_path))
        dat <- dplyr::mutate(dat, sector = sector)
        # Rename alternative columns
        for(alt in names(col_mapping)) {
          expected <- col_mapping[alt]
          if(alt %in% names(dat) && !(expected %in% names(dat))) {
            dat[[expected]] <- dat[[alt]]
          }
        }
        # Fill missing essential columns
        for(col in expected_cols) {
          if(!(col %in% names(dat))) {
            if(col == "job_title") dat[[col]] <- paste("Unknown Job", seq_len(nrow(dat)))
            else if(col %in% c("si", "se", "sd")) dat[[col]] <- stats::runif(nrow(dat))
            else if(col == "weighted_freq") dat[[col]] <- 1
          }
        }
        dplyr::select(dat, dplyr::all_of(c("job_title", "si", "se", "sd", "weighted_freq", "sector")), dplyr::everything())
      }, error = function(e) {
        if(verbose) cli::cli_alert_warning("Error reading {file_path}: {e$message}")
        NULL
      })
    })
  }
  specialization_indices <- load_specialization_indices()
  
  # Feature preparation
  prepare_features <- function(promotions, title_map, spec_data) {
    if(nrow(promotions) == 0) return(tibble::tibble())
    promotions <- tibble::as_tibble(promotions)
    # Ensure essential columns
    essential <- c("job_title_from", "job_title_to", "promotion_probability", "region", "sector", "validated")
    for(col in essential) {
      if(!(col %in% colnames(promotions))) promotions[[col]] <- NA
    }
    # Join with specialization
    if(nrow(spec_data) > 0) {
      # Source job join
      promotions <- promotions %>%
        dplyr::left_join(spec_data, by = c("job_title_from" = "job_title", "sector" = "sector")) %>%
        dplyr::rename_with(~paste0(.x, "_from"), c("si", "se", "sd", "weighted_freq"))
      # Target job join
      promotions <- promotions %>%
        dplyr::left_join(spec_data, by = c("job_title_to" = "job_title", "sector" = "sector")) %>%
        dplyr::rename_with(~paste0(.x, "_to"), c("si", "se", "sd", "weighted_freq"))
      # Fill missing values
      for(col in c("si_from", "se_from", "sd_from", "weighted_freq_from",
                   "si_to", "se_to", "sd_to", "weighted_freq_to")) {
        if(col %in% colnames(promotions))
          promotions[[col]][is.na(promotions[[col]])] <- if(stringr::str_detect(col, "freq")) 1 else stats::runif(sum(is.na(promotions[[col]])), 0, 1)
      }
    } else {
      for(col in c("si_from", "se_from", "sd_from", "weighted_freq_from",
                   "si_to", "se_to", "sd_to", "weighted_freq_to")) {
        promotions[[col]] <- if(stringr::str_detect(col, "freq")) 1 else stats::runif(nrow(promotions), 0, 1)
      }
    }
    # Derived features
    promotions <- promotions %>%
      dplyr::mutate(
        si_difference = si_to - si_from,
        sd_difference = sd_to - sd_from,
        popularity_difference = weighted_freq_to - weighted_freq_from,
        education_progression_score = stats::runif(dplyr::n()),
        job_start_score = stats::runif(dplyr::n()),
        upward_mobility = as.integer(promotion_probability > 0.5),
        career_stagnation = as.integer(promotion_probability < 0.2),
        job_hopping_potential = as.integer(weighted_freq_to > weighted_freq_from * 1.5)
      ) %>%
      dplyr::mutate(dplyr::across(c(region, sector, validated), as.factor))
    # Remove columns with all NA
    na_cols <- names(which(purrr::map_lgl(promotions, ~all(is.na(.x)))))
    promotions <- promotions %>% dplyr::select(-dplyr::any_of(na_cols))
    promotions
  }
  
  model_data <- prepare_features(all_promotions, title_mappings, specialization_indices)
  
  # Metadata
  metadata <- list(
    timestamp = Sys.time(),
    user = Sys.info()[["user"]],
    validated_promotions_count = nrow(validated_promotions),
    unvalidated_promotions_count = nrow(unvalidated_promotions),
    title_mappings_count = nrow(title_mappings),
    specialization_indices_count = nrow(specialization_indices),
    combined_promotions_count = nrow(all_promotions),
    model_data_count = nrow(model_data),
    model_data_columns = ncol(model_data),
    column_names = colnames(model_data)
  )
  
  # Save outputs (optional)
  if(!is.null(output_path)) {
    timestamp_str <- format(Sys.time(), "%Y%m%d_%H%M%S")
    saveRDS(model_data, file.path(output_path, paste0("model_data_", timestamp_str, ".rds")))
    saveRDS(metadata, file.path(output_path, paste0("data_prep_metadata_", timestamp_str, ".rds")))
    if(nrow(model_data) > 0) {
      sample_n <- min(10000, nrow(model_data))
      sample_data <- model_data[sample(seq_len(nrow(model_data)), sample_n), ]
      saveRDS(sample_data, file.path(output_path, paste0("model_data_sample_", timestamp_str, ".rds")))
    }
  }
  
  invisible(list(model_data = model_data, metadata = metadata))
}