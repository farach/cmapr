# Generate Sector Profile

Creates a profile summary for each sector showing key transition
metrics.

## Usage

``` r
sector_profile(model_data, by = "sector", weight = "transition_weighted_count")
```

## Arguments

- model_data:

  A tibble containing career transition data (e.g., from
  load_cmap_data()).

- by:

  Character string specifying the grouping variable. Default is
  "sector".

- weight:

  Character string specifying the weight column. Default is
  "transition_weighted_count".

## Value

A tibble with sector profiles including total transitions, unique job
titles, and average metrics.

## Details

This function creates a comprehensive sector profile including: - Total
number of transitions - Total weighted transitions - Number of unique
job titles (from and to) - Average specialization indices if available

## Examples

``` r
if (FALSE) { # \dontrun{
result <- load_cmap_data(base_path = "~/cmap_data")
profile <- sector_profile(result$model_data, by = "sector")
} # }
```
