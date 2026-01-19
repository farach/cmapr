# Get Network Summary Statistics

Calculates common network metrics for a promotion graph.

## Usage

``` r
network_summary(edges, sector = NULL)
```

## Arguments

- edges:

  A tibble of promotion edges, or an igraph/tidygraph object.

- sector:

  Optional character string to filter by sector (only used if edges is a
  tibble).

## Value

A tibble with network summary statistics including:

- n_nodes:

  Number of unique job titles (nodes).

- n_edges:

  Number of promotion transitions (edges).

- density:

  Graph density (proportion of possible edges that exist).

- avg_in_degree:

  Average number of incoming promotions per title.

- avg_out_degree:

  Average number of outgoing promotions per title.

- n_components:

  Number of weakly connected components.

- largest_component_size:

  Size of the largest connected component.

- diameter:

  Diameter of the largest component (longest shortest path).

## Examples

``` r
if (FALSE) { # \dontrun{
edges <- load_validated_promotions("edges", "~/cmap_data/promotions/validated")
stats <- network_summary(edges)
print(stats)

# By sector
stats_finance <- network_summary(edges, sector = "finance")
} # }
```
