# Convert Promotion Edges to igraph Object

Converts promotion edge data into an igraph directed graph object for
network analysis. Preserves all edge attributes from the original data.

## Usage

``` r
as_igraph(edges, sector = NULL, directed = TRUE, add_node_attrs = TRUE)
```

## Arguments

- edges:

  A tibble of promotion edges (from \`load_validated_promotions("edges",
  ...)\` or \`load_unvalidated_promotions("edges", ...)\`).

- sector:

  Optional character string to filter edges by sector before conversion.

- directed:

  Logical; if TRUE (default), creates a directed graph.

- add_node_attrs:

  Logical; if TRUE (default), adds node-level attributes like in-degree,
  out-degree, and whether the node is a source/sink.

## Value

An igraph graph object with:

- vertices:

  Job titles as nodes with optional degree attributes.

- edges:

  Promotion transitions with all original attributes preserved.

## Details

This function requires the igraph package to be installed. The resulting
graph can be analyzed using any igraph function (centrality, community
detection, path finding, etc.).

Edge attributes from the original data (frequency, probability, sector,
etc.) are preserved and accessible via \`igraph::edge_attr()\`.

## See also

\[as_tidygraph()\] for tidygraph conversion

## Examples

``` r
if (FALSE) { # \dontrun{
edges <- load_validated_promotions("edges", "~/cmap_data/promotions/validated")

# Convert to igraph
g <- as_igraph(edges)

# Basic network analysis
igraph::vcount(g)
igraph::ecount(g)
igraph::diameter(g)

# Centrality analysis
top_central <- igraph::page_rank(g)$vector |> sort(decreasing = TRUE) |> head(10)

# Filter by sector first
g_finance <- as_igraph(edges, sector = "finance")
} # }
```
