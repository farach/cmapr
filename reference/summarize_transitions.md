# Summarize Career Transitions

Aggregates transition counts and weights by specified grouping
variables.

## Usage

``` r
summarize_transitions(
  model_data,
  by = c("sector", "region"),
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

- weight:

  Character string specifying the weight column to sum. Default is
  "transition_weighted_count".

## Value

A tibble with grouped transition summaries including total transitions
and total weighted transitions.

## Details

This function groups the model_data by the specified variables and
calculates: - n_transitions: count of transitions - total_weight: sum of
the weight column

## Examples

``` r
if (FALSE) { # \dontrun{
result <- load_cmap_data(base_path = "~/cmap_data")
summary <- summarize_transitions(result$model_data, by = c("sector", "region"))
} # }
```
