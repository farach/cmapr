#' Helper: List all CSV files recursively
#' @param dir_path Path to directory
#' @return Character vector of file paths
find_csv_files <- function(dir_path) {
  list.files(dir_path, pattern = "\\.csv$", full.names = TRUE, recursive = TRUE)
}

#' Validate Directory Exists
#'
#' Checks if a directory exists and aborts with a helpful error message if not.
#'
#' @param path Character string specifying the directory path to validate.
#' @param label Character string used in the error message to describe the path. Default is "path".
#' @return Invisibly returns TRUE if the directory exists.
#' @importFrom cli cli_abort
validate_dir <- function(path, label = "path") {
  if (!dir.exists(path)) {
    cli::cli_abort(c(
      "x" = "Directory does not exist: {.path {path}}",
      "i" = "Please check that the {label} is correct and the directory exists."
    ))
  }
  invisible(TRUE)
}

#' Read and Row-Bind Multiple CSV Files
#'
#' Reads multiple CSV files and combines them into a single tibble using either readr or vroom.
#'
#' @param paths Character vector of file paths to read.
#' @param reader Character string specifying which CSV reader to use: "readr" (default) or "vroom".
#' @return A tibble containing all rows from the input CSV files.
#' @importFrom readr read_csv
#' @importFrom purrr map list_rbind
read_csvs <- function(paths, reader = c("readr", "vroom")) {
  reader <- match.arg(reader)

  if (length(paths) == 0) {
    return(tibble::tibble())
  }

  if (reader == "vroom") {
    if (!requireNamespace("vroom", quietly = TRUE)) {
      cli::cli_warn(c(
        "!" = "Package 'vroom' not available, falling back to 'readr'.",
        "i" = "Install with: install.packages('vroom')"
      ))
      reader <- "readr"
    }
  }

  read_fn <- if (reader == "vroom") {
    \(x) vroom::vroom(x, show_col_types = FALSE)
  } else {
    \(x) readr::read_csv(x, show_col_types = FALSE)
  }

  purrr::map(paths, read_fn) |> purrr::list_rbind()
}

#' Normalize Column Names
#'
#' Optionally cleans column names using janitor::clean_names().
#'
#' @param df A data frame or tibble.
#' @param clean Logical; if TRUE (default), applies janitor::clean_names() to standardize column names.
#' @return The data frame with optionally cleaned column names.
#' @importFrom janitor clean_names
normalize_names <- function(df, clean = TRUE) {
  if (clean) {
    df <- janitor::clean_names(df)
  }
  df
}

#' Standardized CLI Logging
#'
#' Provides consistent logging messages using cli functions.
#'
#' @param level Character string specifying the log level: "info", "success", or "warn".
#' @param message Character string with the message to log.
#' @param ... Additional arguments passed to the cli function.
#' @importFrom cli cli_alert_info cli_alert_success cli_alert_warning
#' @importFrom rlang caller_env
cmap_log <- function(level = c("info", "success", "warn"), message, ...) {
  level <- match.arg(level)
  envir <- rlang::caller_env()

  switch(level,
         info = cli::cli_alert_info(message, ..., .envir = envir),
         success = cli::cli_alert_success(message, ..., .envir = envir),
         warn = cli::cli_alert_warning(message, ..., .envir = envir)
  )
}

#' Classify Job Title Type
#'
#' Coarse heuristic classifier for job titles based on keyword patterns.
#' Classifies titles into Managerial, Technical, Entry-level, or Other categories.
#'
#' @param title Character vector of job titles to classify.
#' @return Character vector of classified title types.
#' @importFrom dplyr case_when
#' @importFrom stringr str_detect regex
#' @keywords internal
classify_title_type <- function(title) {
  dplyr::case_when(
    stringr::str_detect(title, stringr::regex("manager|director|lead|chief|head|executive", ignore_case = TRUE)) ~ "Managerial",
    stringr::str_detect(title, stringr::regex("engineer|developer|analyst|scientist|technician", ignore_case = TRUE)) ~ "Technical",
    stringr::str_detect(title, stringr::regex("assistant|junior|intern|trainee", ignore_case = TRUE)) ~ "Entry-level",
    TRUE ~ "Other"
  )
}
