# =============================================================================
# Test Script for cmapr README Examples
# =============================================================================
# Run this script to verify all README examples work correctly.
# Usage: source("inst/scripts/test_readme_examples.R")
# Or run interactively section by section.
# =============================================================================
library(cmapr)
library(dplyr)

cat("\n")
cat("=============================================================================\n")
cat("                    cmapr README Examples Test Script
\n")
cat("=============================================================================\n\n")

# -----------------------------------------------------------------------------
# Setup: Download data if needed
# -----------------------------------------------------------------------------
cat(">>> Setting up data directory...\n")
dataset_dir <- download_cmap_data("~/cmap_data")
cat("Dataset directory:", dataset_dir, "\n\n")

# -----------------------------------------------------------------------------
# Test 1: Load Core Data
# -----------------------------------------------------------------------------
cat("=== TEST 1: Load Core Data (load_cmap_data) ===\n")
cat("This may take a minute on first run...\n")

t1 <- system.time({
result <- load_cmap_data(base_path = dataset_dir, verbose = FALSE)
})

model_data <- result$model_data
metadata <- result$metadata

cat("Time:", round(t1["elapsed"], 2), "seconds\n")
cat("model_data rows:", nrow(model_data), "\n")
cat("model_data cols:", ncol(model_data), "\n")
cat("Columns:", paste(head(names(model_data), 10), collapse = ", "), "...\n")
cat("TEST 1: PASSED\n\n")

# -----------------------------------------------------------------------------
# Test 2: Explore Job Title Specialization
# -----------------------------------------------------------------------------
cat("=== TEST 2: Load Sector Specialization ===\n")

t2 <- system.time({
  si_data <- load_sector_specialization(file.path(dataset_dir, "titles/si"), verbose = FALSE)
})

cat("Time:", round(t2["elapsed"], 2), "seconds\n")
cat("si_data rows:", nrow(si_data), "\n")
cat("si_data cols:", ncol(si_data), "\n")
cat("Columns:", paste(names(si_data), collapse = ", "), "\n")

# Test the dplyr pipeline from README
top_si <- si_data |>
  group_by(sector) |>
  arrange(desc(si)) |>
  slice_head(n = 3)

cat("Top specialized titles (sample):\n")
print(head(top_si, 6))
cat("TEST 2: PASSED\n\n")

# -----------------------------------------------------------------------------
# Test 3: Job Title Mapping (Optimized)
# -----------------------------------------------------------------------------
cat("=== TEST 3: Load Title Map ===\n")

# Test 3a: Fast load (default - no features)
cat("\n3a. Fast load (add_features=FALSE, default)...\n")
t3a <- system.time({
  title_map <- load_title_map(file.path(dataset_dir, "titles/map"), verbose = FALSE)
})
cat("Time:", round(t3a["elapsed"], 2), "seconds\n")
cat("title_map rows:", nrow(title_map), "\n")
cat("title_map cols:", ncol(title_map), "\n")
cat("Columns:", paste(names(title_map), collapse = ", "), "\n")

# Test 3b: With features (slower)
cat("\n3b. With features (add_features=TRUE)...\n")
t3b <- system.time({
  title_map_features <- load_title_map(
    file.path(dataset_dir, "titles/map"),
    add_features = TRUE,
    verbose = FALSE
  )
})
cat("Time:", round(t3b["elapsed"], 2), "seconds\n")
cat("title_map_features cols:", ncol(title_map_features), "\n")
cat("Added columns:", paste(setdiff(names(title_map_features), names(title_map)), collapse = ", "), "\n")

# Test 3c: Filtered load (single sector)
cat("\n3c. Filtered load (single sector)...\n")
t3c <- system.time({
  tech_titles <- load_title_map(
    file.path(dataset_dir, "titles/map"),
    sector_filter = "Information Technology",
    verbose = FALSE
  )
})
cat("Time:", round(t3c["elapsed"], 2), "seconds\n")
cat("tech_titles rows:", nrow(tech_titles), "\n")

# Test count from README
title_counts <- title_map |>
  count(sector, title_cleaned, sort = TRUE)

cat("\nTitle counts (sample):\n")
print(head(title_counts, 5))
cat("TEST 3: PASSED\n\n")

# -----------------------------------------------------------------------------
# Test 4a: Validated Promotions
# -----------------------------------------------------------------------------
cat("=== TEST 4a: Load Validated Promotions ===\n")

t4a <- system.time({
  validated_edges <- load_validated_promotions("edges", file.path(dataset_dir, "promotions/validated"))
})

cat("Time:", round(t4a["elapsed"], 2), "seconds\n")
cat("validated_edges rows:", nrow(validated_edges), "\n")
cat("validated_edges cols:", ncol(validated_edges), "\n")
cat("Columns:", paste(names(validated_edges), collapse = ", "), "\n")

t4a_nodes <- system.time({
  validated_nodes <- load_validated_promotions("nodes", file.path(dataset_dir, "promotions/validated"))
})

cat("validated_nodes rows:", nrow(validated_nodes), "\n")
cat("TEST 4a: PASSED\n\n")

# -----------------------------------------------------------------------------
# Test 4b: Unvalidated Promotions
# -----------------------------------------------------------------------------
cat("=== TEST 4b: Load Unvalidated Promotions ===\n")

t4b <- system.time({
  unvalidated_edges <- load_unvalidated_promotions("edges", file.path(dataset_dir, "promotions/unvalidated"))
})

cat("Time:", round(t4b["elapsed"], 2), "seconds\n")
cat("unvalidated_edges rows:", nrow(unvalidated_edges), "\n")
cat("unvalidated_edges cols:", ncol(unvalidated_edges), "\n")
cat("Columns:", paste(names(unvalidated_edges), collapse = ", "), "\n")

t4b_nodes <- system.time({
  unvalidated_nodes <- load_unvalidated_promotions("nodes", file.path(dataset_dir, "promotions/unvalidated"))
})

cat("unvalidated_nodes rows:", nrow(unvalidated_nodes), "\n")
cat("TEST 4b: PASSED\n\n")

# -----------------------------------------------------------------------------
# Test 4c: List Network Files
# -----------------------------------------------------------------------------
cat("=== TEST 4c: List Network Visualizations ===\n")

networks_validated <- load_validated_promotions("network", file.path(dataset_dir, "promotions/validated"))
cat("Validated network files:", length(networks_validated), "\n")
cat("Sample files:", paste(head(networks_validated, 3), collapse = ", "), "\n")

networks_unvalidated <- load_unvalidated_promotions("network", file.path(dataset_dir, "promotions/unvalidated"))
cat("Unvalidated network files:", length(networks_unvalidated), "\n")
cat("Sample files:", paste(head(networks_unvalidated, 3), collapse = ", "), "\n")
cat("TEST 4c: PASSED\n\n")

# -----------------------------------------------------------------------------
# Test 5: Summarization Functions
# -----------------------------------------------------------------------------
cat("=== TEST 5: Summarization Functions ===\n")

# 5a: summarize_transitions
cat("\n5a. summarize_transitions()...\n")
summary_result <- summarize_transitions(model_data, by = c("sector", "region"))
cat("Rows:", nrow(summary_result), "\n")
print(head(summary_result, 3))

# 5b: top_transitions
cat("\n5b. top_transitions()...\n")
top_10 <- top_transitions(model_data, by = "sector", n = 3)
cat("Rows:", nrow(top_10), "\n")
print(head(top_10[, c("sector", "job_title_from", "job_title_to", "transition_weighted_count")], 5))

# 5c: promotion_rate (using correct column name)
cat("\n5c. promotion_rate()...\n")
cat("Note: validated_edges uses 'country_binned' not 'region'\n")
rates <- promotion_rate(validated_edges, by = c("sector", "country_binned"))
cat("Rows:", nrow(rates), "\n")
print(head(rates, 5))

# 5d: sector_profile
cat("\n5d. sector_profile()...\n")
profiles <- sector_profile(model_data, by = "sector")
cat("Rows:", nrow(profiles), "\n")
print(head(profiles, 5))

# 5e: title_frequency
cat("\n5e. title_frequency()...\n")
title_freq <- title_frequency(title_map, by = "sector", n = 5)
cat("Rows:", nrow(title_freq), "\n")
print(head(title_freq[, c("sector", "title_cleaned", "frequency_cleaned")], 5))

cat("\nTEST 5: PASSED\n\n")

# -----------------------------------------------------------------------------
# Test 6: Career Path Analysis
# -----------------------------------------------------------------------------
cat("=== TEST 6: Career Path Analysis ===\n")

# 6a: find_career_paths
cat("\n6a. find_career_paths()...\n")
t6a <- system.time({
  paths <- find_career_paths(
    validated_edges,
    from = "analyst",
    to = "manager",
    max_depth = 4
  )
})
cat("Time:", round(t6a["elapsed"], 2), "seconds\n")
cat("Paths found:", paths$n_paths, "\n")
if (paths$n_paths > 0) {
  cat("Shortest path length:", min(paths$summary$path_length), "\n")
  print(head(paths$summary, 3))
}

# 6b: career_ladder
cat("\n6b. career_ladder()...\n")
t6b <- system.time({
  ladder <- career_ladder(
    unvalidated_edges,
    start_title = "analyst",
    depth = 3,
    top_n = 3
  )
})
cat("Time:", round(t6b["elapsed"], 2), "seconds\n")
cat("Ladder positions:", nrow(ladder$ladder), "\n")
if (nrow(ladder$ladder) > 0) {
  print(head(ladder$ladder, 5))
}

cat("TEST 6: PASSED\n\n")

# -----------------------------------------------------------------------------
# Test 7: Network Analysis Integration
# -----------------------------------------------------------------------------
cat("=== TEST 7: Network Analysis Integration ===\n")

if (requireNamespace("igraph", quietly = TRUE)) {
  # 7a: as_igraph
  cat("\n7a. as_igraph()...\n")
  t7a <- system.time({
    g <- as_igraph(validated_edges, sector = "Accounting & Legal")
  })
  cat("Time:", round(t7a["elapsed"], 2), "seconds\n")
  cat("Nodes:", igraph::vcount(g), "\n")
  cat("Edges:", igraph::ecount(g), "\n")

  # 7b: network_summary
  cat("\n7b. network_summary()...\n")
  t7b <- system.time({
    net_stats <- network_summary(validated_edges, sector = "Accounting & Legal")
  })
  cat("Time:", round(t7b["elapsed"], 2), "seconds\n")
  print(net_stats)

  cat("TEST 7: PASSED\n\n")
} else {
  cat("Skipping TEST 7: igraph package not installed\n\n")
}

if (requireNamespace("tidygraph", quietly = TRUE)) {
  # 7c: as_tidygraph
  cat("\n7c. as_tidygraph()...\n")
  t7c <- system.time({
    tg <- as_tidygraph(validated_edges, sector = "Health Care")
  })
  cat("Time:", round(t7c["elapsed"], 2), "seconds\n")
  cat("tidygraph object created successfully\n")
} else {
  cat("Skipping tidygraph test: tidygraph package not installed\n")
}

# -----------------------------------------------------------------------------
# Test 8: Example Data
# -----------------------------------------------------------------------------
cat("=== TEST 8: Example Data ===\n")

example_path <- cmap_example_data()
cat("Example data path:", example_path, "\n")

if (nzchar(example_path) && file.exists(example_path)) {
  example_df <- readr::read_csv(example_path, show_col_types = FALSE)
  cat("Example data rows:", nrow(example_df), "\n")
  cat("Example data cols:", ncol(example_df), "\n")
  cat("Columns:", paste(names(example_df), collapse = ", "), "\n")
  cat("TEST 8: PASSED\n\n")
} else {
  cat("Example data file not found (this is OK if package not installed)\n")
  cat("TEST 8: SKIPPED\n\n")
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
cat("=============================================================================\n")
cat("                           ALL TESTS COMPLETED
\n")
cat("=============================================================================\n")
cat("\nTiming Summary:\n")
cat("  load_cmap_data:              ", round(t1["elapsed"], 2), "s\n")
cat("  load_sector_specialization: ", round(t2["elapsed"], 2), "s\n")
cat("  load_title_map (fast):      ", round(t3a["elapsed"], 2), "s\n")
cat("  load_title_map (features):  ", round(t3b["elapsed"], 2), "s\n")
cat("  load_title_map (filtered):  ", round(t3c["elapsed"], 2), "s\n")
cat("  load_validated_promotions:  ", round(t4a["elapsed"], 2), "s\n")
cat("  load_unvalidated_promotions:", round(t4b["elapsed"], 2), "s\n")
cat("  find_career_paths:          ", round(t6a["elapsed"], 2), "s\n")
cat("  career_ladder:              ", round(t6b["elapsed"], 2), "s\n")
if (exists("t7a")) cat("  as_igraph:                  ", round(t7a["elapsed"], 2), "s\n")
if (exists("t7b")) cat("  network_summary:            ", round(t7b["elapsed"], 2), "s\n")
cat("\nAll README examples executed successfully!\n")
