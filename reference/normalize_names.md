# Normalize Column Names

Optionally cleans column names using janitor::clean_names().

## Usage

``` r
normalize_names(df, clean = TRUE)
```

## Arguments

- df:

  A data frame or tibble.

- clean:

  Logical; if TRUE (default), applies janitor::clean_names() to
  standardize column names.

## Value

The data frame with optionally cleaned column names.
