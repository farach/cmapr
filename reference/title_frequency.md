# Calculate Title Frequency

Summarizes the most frequent job titles from the title mapping data.

## Usage

``` r
title_frequency(title_map, by = c("sector", "region"), n = 10)
```

## Arguments

- title_map:

  A tibble containing title mapping data (e.g., from load_title_map()).

- by:

  Character vector specifying grouping variables. Default is c("sector",
  "region").

- n:

  Integer specifying the number of top titles to return per group.
  Default is 10.

## Value

A tibble with the top N most frequent titles per group.

## Details

This function identifies frequency columns in the title map data and
returns the top N titles by frequency within each group. It looks for
columns like 'frequency', 'frequency_simplified', or
'weighted_frequency'.

## Examples

``` r
if (FALSE) { # \dontrun{
title_map <- load_title_map("~/cmap_data/titles/map")
freq <- title_frequency(title_map, by = "sector", n = 20)
} # }
```
