# Package index

## Data Loading

Functions to download and load CMap data

- [`download_cmap_data()`](https://farach.github.io/cmapr/reference/download_cmap_data.md)
  : Download the CMap Career Mobility Dataset from Zenodo
- [`load_cmap_data()`](https://farach.github.io/cmapr/reference/load_cmap_data.md)
  : CMap Data Loader
- [`load_title_map()`](https://farach.github.io/cmapr/reference/load_title_map.md)
  : Load and Augment Job Title Mapping Data
- [`load_sector_specialization()`](https://farach.github.io/cmapr/reference/load_sector_specialization.md)
  : Load and Augment Sector-Specific Title Specialization Data
- [`load_validated_promotions()`](https://farach.github.io/cmapr/reference/load_validated_promotions.md)
  : Load Validated Promotions Data
- [`load_unvalidated_promotions()`](https://farach.github.io/cmapr/reference/load_unvalidated_promotions.md)
  : Load Unvalidated Promotions Data
- [`cmap_example_data()`](https://farach.github.io/cmapr/reference/cmap_example_data.md)
  : Get Path to Example Data

## Career Path Analysis

Analyze promotion paths and career progressions

- [`find_career_paths()`](https://farach.github.io/cmapr/reference/find_career_paths.md)
  : Find Career Paths Between Two Titles
- [`career_ladder()`](https://farach.github.io/cmapr/reference/career_ladder.md)
  : Explore Career Ladder from a Starting Title

## Network Analysis

Convert data for graph/network analysis

- [`as_igraph()`](https://farach.github.io/cmapr/reference/as_igraph.md)
  : Convert Promotion Edges to igraph Object
- [`as_tidygraph()`](https://farach.github.io/cmapr/reference/as_tidygraph.md)
  : Convert Promotion Edges to tidygraph Object
- [`network_summary()`](https://farach.github.io/cmapr/reference/network_summary.md)
  : Get Network Summary Statistics

## Data Summarization

Summarize and analyze career transitions

- [`summarize_transitions()`](https://farach.github.io/cmapr/reference/summarize_transitions.md)
  : Summarize Career Transitions
- [`top_transitions()`](https://farach.github.io/cmapr/reference/top_transitions.md)
  : Top Career Transitions
- [`promotion_rate()`](https://farach.github.io/cmapr/reference/promotion_rate.md)
  : Calculate Promotion Rate
- [`sector_profile()`](https://farach.github.io/cmapr/reference/sector_profile.md)
  : Generate Sector Profile
- [`title_frequency()`](https://farach.github.io/cmapr/reference/title_frequency.md)
  : Calculate Title Frequency

## Utilities

Helper functions

- [`find_csv_files()`](https://farach.github.io/cmapr/reference/find_csv_files.md)
  : Helper: List all CSV files recursively
- [`read_csvs()`](https://farach.github.io/cmapr/reference/read_csvs.md)
  : Read and Row-Bind Multiple CSV Files
- [`normalize_names()`](https://farach.github.io/cmapr/reference/normalize_names.md)
  : Normalize Column Names
- [`validate_dir()`](https://farach.github.io/cmapr/reference/validate_dir.md)
  : Validate Directory Exists
- [`cmap_log()`](https://farach.github.io/cmapr/reference/cmap_log.md) :
  Standardized CLI Logging
- [`model_data`](https://farach.github.io/cmapr/reference/model_data.md)
  : CMap Career Mobility Data
