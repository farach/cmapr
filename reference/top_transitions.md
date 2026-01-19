# Top Career Transitions

Returns the top N transitions by weight within each group.

## Usage

``` r
top_transitions(
  model_data,
  by = c("sector", "region"),
  n = 10,
  weight = "transition_weighted_count"
)
```

## Arguments

- model_data:

  A tibble containing career transition data (e.g., from
  load_cmap_data()).

- by:

  Character vector specifying grouping variables. Default is c("sector",
  "region").

- n:

  Integer specifying the number of top transitions to return per group.
  Default is 10.

- weight:

  Character string specifying the weight column to rank by. Default is
  "transition_weighted_count".

## Value

A tibble with the top N transitions per group, ranked by weight.

## Details

This function groups the model_data by the specified variables and
returns the top N rows (ranked by the weight column) for each group.

## Examples

``` r
if (FALSE) { # \dontrun{
result <- load_cmap_data(base_path = "~/cmap_data")
top <- top_transitions(result$model_data, by = "sector", n = 5)
} # }
```
