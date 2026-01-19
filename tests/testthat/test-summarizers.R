# Tests for summarizer functions

# Create sample data for testing
create_test_model_data <- function() {
  tibble::tibble(
    sector = c("Tech", "Tech", "Finance", "Finance", "Healthcare"),
    region = c("US", "EU", "US", "EU", "US"),
    job_title_from = c("Engineer", "Developer", "Analyst", "Trader", "Nurse"),
    job_title_to = c("Senior Engineer", "Lead Developer", "Senior Analyst", "Senior Trader", "Head Nurse"),
    transition_weighted_count = c(100, 80, 90, 70, 60),
    si_from = c(0.8, 0.75, 0.85, 0.9, 0.7),
    si_to = c(0.85, 0.8, 0.88, 0.92, 0.75)
  )
}

create_test_title_map <- function() {
  tibble::tibble(
    sector = c("Tech", "Tech", "Finance", "Finance"),
    title_cleaned = c("Engineer", "Developer", "Analyst", "Trader"),
    frequency = c(1000, 800, 900, 700),
    frequency_cleaned = c(1000, 800, 900, 700)
  )
}

# Tests for summarize_transitions
test_that("summarize_transitions returns correct structure", {
  data <- create_test_model_data()

  result <- summarize_transitions(data, by = "sector")

  expect_s3_class(result, "tbl_df")
  expect_true("sector" %in% names(result))
  expect_true("n_transitions" %in% names(result))
  expect_true("total_weight" %in% names(result))
})

test_that("summarize_transitions groups correctly", {
  data <- create_test_model_data()

  result <- summarize_transitions(data, by = "sector")

  expect_equal(nrow(result), 3) # Tech, Finance, Healthcare
})

test_that("summarize_transitions errors on non-dataframe input", {
  expect_error(
    summarize_transitions("not a dataframe"),
    "must be a data frame"
  )
})

test_that("summarize_transitions errors on missing grouping variable", {
  data <- create_test_model_data()

  expect_error(
    summarize_transitions(data, by = "nonexistent_column"),
    "not found"
  )
})

test_that("summarize_transitions errors on missing weight column", {
  data <- create_test_model_data()

  expect_error(
    summarize_transitions(data, weight = "nonexistent_weight"),
    "not found"
  )
})

# Tests for top_transitions
test_that("top_transitions returns correct number of rows per group", {
  data <- create_test_model_data()

  result <- top_transitions(data, by = "sector", n = 1)

  # Should return 1 row per sector (3 sectors)
  expect_equal(nrow(result), 3)
})

test_that("top_transitions returns highest weight first", {
  data <- create_test_model_data()

  result <- top_transitions(data, by = "sector", n = 2)

  # Tech sector should have highest weight row first
  tech_rows <- result[result$sector == "Tech", ]
  expect_true(tech_rows$transition_weighted_count[1] >= tech_rows$transition_weighted_count[2])
})

test_that("top_transitions errors on invalid inputs", {
  data <- create_test_model_data()

  expect_error(top_transitions("not a dataframe"), "must be a data frame")
  expect_error(top_transitions(data, by = "fake"), "not found")
})

# Tests for promotion_rate
test_that("promotion_rate returns correct structure", {
  data <- tibble::tibble(
    sector = c("Tech", "Tech", "Finance"),
    region = c("US", "US", "EU"),
    promoted = c(1, 0, 1)
  )

  result <- promotion_rate(data, by = "sector")

  expect_s3_class(result, "tbl_df")
  expect_true("promotion_rate" %in% names(result))
})

test_that("promotion_rate calculates correctly", {
  data <- tibble::tibble(
    sector = c("Tech", "Tech", "Tech", "Tech"),
    region = c("US", "US", "US", "US"),
    promoted = c(1, 1, 0, 0)
  )

  result <- promotion_rate(data, by = "sector")

  expect_equal(result$promotion_rate[1], 0.5)
})

test_that("promotion_rate handles missing promotion column", {
  data <- tibble::tibble(
    sector = c("Tech", "Finance"),
    region = c("US", "EU")
  )

  result <- promotion_rate(data, by = "sector")

  # Should assume all are promotions
  expect_equal(result$promotion_rate[1], 1.0)
})

# Tests for sector_profile
test_that("sector_profile returns correct structure", {
  data <- create_test_model_data()

  result <- sector_profile(data)

  expect_s3_class(result, "tbl_df")
  expect_true(all(c("sector", "n_transitions", "total_weight") %in% names(result)))
})
test_that("sector_profile includes SI metrics when available", {
  data <- create_test_model_data()

  result <- sector_profile(data)

  expect_true("avg_si_from" %in% names(result))
  expect_true("avg_si_to" %in% names(result))
})

# Tests for title_frequency
test_that("title_frequency returns correct structure", {
  data <- create_test_title_map()

  result <- title_frequency(data, by = "sector", n = 2)

  expect_s3_class(result, "tbl_df")
  expect_true("sector" %in% names(result))
})

test_that("title_frequency respects n parameter", {
  data <- create_test_title_map()

  result <- title_frequency(data, by = "sector", n = 1)

  # Should have 1 row per sector
  expect_equal(nrow(result), 2) # Tech and Finance
})

test_that("title_frequency errors on missing frequency column", {
  data <- tibble::tibble(
    sector = c("Tech", "Finance"),
    title = c("Engineer", "Analyst")
  )

  expect_error(
    title_frequency(data, by = "sector"),
    "No frequency column found"
  )
})

test_that("title_frequency warns on partial grouping variables", {
  data <- create_test_title_map()

  expect_warning(
    title_frequency(data, by = c("sector", "nonexistent")),
    "not found"
  )
})
