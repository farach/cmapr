# Calculate Promotion Rate

Calculates promotion rates from validated promotions data.

## Usage

``` r
promotion_rate(validated_promotions, by = c("sector", "region"))
```

## Arguments

- validated_promotions:

  A tibble containing validated promotion data (e.g., from
  load_validated_promotions("edges", ...)).

- by:

  Character vector specifying grouping variables. Default is c("sector",
  "region").

## Value

A tibble with promotion rates by group.

## Details

This function calculates the promotion rate as the mean of a binary
promotion indicator. The data is expected to have columns for grouping
(sector, region, etc.). If a 'promoted' or 'is_promotion' column exists,
it will be used; otherwise, the function will calculate based on
available metrics.

## Examples

``` r
if (FALSE) { # \dontrun{
validated <- load_validated_promotions("edges", "~/cmap_data/promotions/validated")
rates <- promotion_rate(validated, by = c("sector", "region"))
} # }
```
