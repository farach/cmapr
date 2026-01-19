# Tests for data.R functions

test_that("cmap_example_data returns a path", {
  result <- cmap_example_data()

  expect_type(result, "character")
})

test_that("cmap_example_data returns path to example_transitions.csv by default", {
  result <- cmap_example_data()

  # Should either be empty (file doesn't exist) or end with the expected filename
  if (nzchar(result)) {
    expect_true(grepl("example_transitions\\.csv$", result))
  }
})

test_that("cmap_example_data accepts custom file parameter", {
  result <- cmap_example_data(file = "custom_file.csv")

  # Should return empty string since custom_file.csv doesn't exist
  expect_equal(result, "")
})
