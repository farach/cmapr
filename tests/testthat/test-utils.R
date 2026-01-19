# Tests for utility functions

test_that("find_csv_files returns character vector", {
  # Create temp directory with CSV files

temp_dir <- tempdir()
  temp_csv <- file.path(temp_dir, "test.csv")
  write.csv(data.frame(x = 1:3), temp_csv, row.names = FALSE)

  result <- cmapr:::find_csv_files(temp_dir)

  expect_type(result, "character")
  expect_true(any(grepl("test\\.csv$", result)))

  # Cleanup
  unlink(temp_csv)
})

test_that("find_csv_files returns empty for non-existent directory", {
  fake_dir <- file.path(tempdir(), "nonexistent_dir_12345")
  result <- cmapr:::find_csv_files(fake_dir)

  expect_type(result, "character")
  expect_length(result, 0)
})

test_that("validate_dir throws error for non-existent directory", {
  fake_dir <- file.path(tempdir(), "nonexistent_validate_test")

  expect_error(
    cmapr:::validate_dir(fake_dir),
    "Directory does not exist"
  )
})

test_that("validate_dir returns TRUE for existing directory", {
  existing_dir <- tempdir()

  result <- cmapr:::validate_dir(existing_dir)

  expect_true(result)
})

test_that("read_csvs returns empty tibble for empty paths", {
  result <- cmapr:::read_csvs(character(0))

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("read_csvs reads and combines CSV files", {
  temp_dir <- tempdir()
  csv1 <- file.path(temp_dir, "test1.csv")
  csv2 <- file.path(temp_dir, "test2.csv")

  write.csv(data.frame(a = 1:2, b = c("x", "y")), csv1, row.names = FALSE)
  write.csv(data.frame(a = 3:4, b = c("z", "w")), csv2, row.names = FALSE)

  result <- cmapr:::read_csvs(c(csv1, csv2))

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4)
  expect_equal(ncol(result), 2)

  # Cleanup
  unlink(c(csv1, csv2))
})

test_that("normalize_names cleans column names when clean = TRUE", {
  df <- data.frame(`Column Name` = 1, `Another.Column` = 2, check.names = FALSE)

  result <- cmapr:::normalize_names(df, clean = TRUE)

  expect_true(all(names(result) == janitor::make_clean_names(names(df))))
})

test_that("normalize_names preserves names when clean = FALSE", {
  df <- data.frame(`Column Name` = 1, `Another.Column` = 2, check.names = FALSE)
  original_names <- names(df)

  result <- cmapr:::normalize_names(df, clean = FALSE)

  expect_equal(names(result), original_names)
})
