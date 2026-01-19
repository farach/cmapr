# Explore Career Ladder from a Starting Title

Discovers common career progressions from a starting job title, showing
the most frequent next steps and building a promotion ladder.

## Usage

``` r
career_ladder(
  edges,
  start_title,
  depth = 3,
  sector = NULL,
  min_frequency = 1,
  top_n = 5,
  ignore_case = TRUE
)
```

## Arguments

- edges:

  A tibble of promotion edges.

- start_title:

  Character string specifying the starting job title.

- depth:

  Integer specifying how many promotion levels to explore. Default is 3.

- sector:

  Optional character string to filter edges by sector.

- min_frequency:

  Minimum edge frequency/weight to include. Default is 1.

- top_n:

  Integer specifying number of top transitions to show at each level.
  Default is 5.

- ignore_case:

  Logical; if TRUE (default), performs case-insensitive title matching.

## Value

A list containing:

- ladder:

  A tibble showing the career ladder with levels, titles, and
  frequencies.

- tree:

  A nested list representation of the career progression tree.

- start_title:

  The matched starting title.

## Details

This function explores the promotion network starting from a given
title, identifying the most common "next step" promotions at each level.
This helps answer questions like "What do software engineers typically
get promoted to?"

## Examples

``` r
if (FALSE) { # \dontrun{
edges <- load_unvalidated_promotions("edges", "~/cmap_data/promotions/unvalidated")

# Explore career ladder from software engineer
ladder <- career_ladder(edges, start_title = "software engineer", depth = 4)
print(ladder$ladder)

# Filter by sector and minimum frequency
ladder <- career_ladder(edges, start_title = "analyst",
                        sector = "finance", min_frequency = 10)
} # }
```
