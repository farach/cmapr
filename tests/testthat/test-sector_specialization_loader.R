test_that("load_sector_specialization loads and summarizes CSV files", {
  si_dir <- tempfile("cmapr-si-")
  dir.create(si_dir)
  on.exit(unlink(si_dir, recursive = TRUE))

  specialization <- data.frame(
    title = c("Software Engineer", "Engineering Manager"),
    frequency = c(120, 40),
    weighted_frequency = c(0.75, 0.25),
    SE = c(0.02, 0.03),
    SD = c(0.15, 0.20),
    SI = c(0.86, 0.61),
    onet_soc_codes = c("15-1252.00", "11-9041.00")
  )
  utils::write.csv(
    specialization,
    file.path(si_dir, "technology.csv"),
    row.names = FALSE
  )

  result <- load_sector_specialization(
    si_dir,
    summarize = TRUE,
    verbose = FALSE
  )

  expect_named(result, c("si_data", "sector_stats"))
  expect_equal(result$si_data$sector, rep("technology", 2))
  expect_equal(result$si_data$title_type, c("Technical", "Managerial"))
  expect_equal(
    sort(result$sector_stats$title_type),
    c("Managerial", "Technical")
  )
})

test_that("load_sector_specialization summarizes without NLP columns", {
  si_dir <- tempfile("cmapr-si-")
  dir.create(si_dir)
  on.exit(unlink(si_dir, recursive = TRUE))

  specialization <- data.frame(
    title = c("Software Engineer", "Engineering Manager"),
    frequency = c(120, 40),
    weighted_frequency = c(0.75, 0.25),
    SE = c(0.02, 0.03),
    SD = c(0.15, 0.20),
    SI = c(0.86, 0.61),
    onet_soc_codes = c("15-1252.00", "11-9041.00")
  )
  utils::write.csv(
    specialization,
    file.path(si_dir, "technology.csv"),
    row.names = FALSE
  )

  result <- load_sector_specialization(
    si_dir,
    add_nlp = FALSE,
    summarize = TRUE,
    verbose = FALSE
  )

  expect_equal(result$sector_stats$sector, "technology")
  expect_equal(result$sector_stats$n_titles, 2L)
  expect_false("title_type" %in% names(result$sector_stats))
})

test_that("load_sector_specialization errors when no CSV files exist", {
  si_dir <- tempfile("cmapr-si-empty-")
  dir.create(si_dir)
  on.exit(unlink(si_dir, recursive = TRUE))

  expect_error(
    load_sector_specialization(si_dir, verbose = FALSE),
    "No CSV files found"
  )
})
