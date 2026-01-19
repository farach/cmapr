# Load and Augment Job Title Mapping Data

Reads all sector-specific CSV files from \`map_dir\` and combines them
into a single tibble. Optionally standardizes column names, filters
sectors, selects columns, adds derived features, and returns
sector-level summary statistics.

## Usage

``` r
load_title_map(
  map_dir,
  columns = NULL,
  sector_filter = NULL,
  clean = TRUE,
  reader = c("vroom", "readr"),
  add_features = FALSE,
  compute_similarity = FALSE,
  summarize = FALSE,
  verbose = TRUE
)
```

## Arguments

- map_dir:

  Path to the directory containing sector mapping CSV files (e.g.,
  "~/cmap_data/titles/map"). Files are expected to be named like
  "\<sector\>.csv".

- columns:

  Optional character vector of columns to keep (default: NULL = keep
  all).

- sector_filter:

  Optional regex pattern used to filter sectors based on the derived
  \`sector\` column

  (default: NULL = keep all sectors).

- clean:

  Logical; if TRUE (default), standardizes column names using
  janitor::clean_names().

- reader:

  Character string specifying which CSV reader to use: "vroom" (default,
  faster) or "readr".

- add_features:

  Logical; if TRUE, adds derived variables such as title lengths and a
  coarse title type classifier. Default is FALSE for performance.

- compute_similarity:

  Logical; if TRUE, computes token-based Jaccard similarity between
  \`title_cleaned\` and \`title_generalized\`. This is expensive for
  large datasets. Default is FALSE.

- summarize:

  Logical; if TRUE, returns a list with \`title_map\` and
  \`sector_stats\`.

- verbose:

  Logical; if TRUE, emits messages (only in interactive sessions).

## Value

If \`summarize = FALSE\`, a tibble of title mappings. If \`summarize =
TRUE\`, a list with:

- title_map:

  A tibble of the combined mapping data (with optional derived
  features).

- sector_stats:

  A tibble of sector/title-type summary statistics.

## Details

Each CSV should contain (at minimum) title columns such as
\`title_cleaned\` and typically generalized/simplified variants (e.g.,
\`title_generalized\`, \`title_simplified\`) plus frequency fields. If a
\`sector\` column is not present, it is derived from the filename.

\## Performance Notes - Use \`reader = "vroom"\` (default) for fastest
loading - Set \`add_features = FALSE\` (default) to skip derived
columns - Set \`compute_similarity = FALSE\` (default) to skip expensive
similarity computation - Use \`sector_filter\` to load only specific
sectors - Use \`columns\` to load only needed columns

## Examples

``` r
if (FALSE) { # \dontrun{
dataset_dir <- download_cmap_data("~/cmap_data")

# Fast load - just the data (recommended for large datasets)
title_map <- load_title_map(file.path(dataset_dir, "titles/map"))

# Load specific sectors only
tech_titles <- load_title_map(
  file.path(dataset_dir, "titles/map"),
  sector_filter = "technology|information"
)

# Load with features (slower)
title_map <- load_title_map(
  file.path(dataset_dir, "titles/map"),
  add_features = TRUE
)

# With summaries
res <- load_title_map(
  file.path(dataset_dir, "titles/map"),
  add_features = TRUE,
  summarize = TRUE
)
} # }
```
