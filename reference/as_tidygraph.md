# Convert Promotion Edges to tidygraph Object

Converts promotion edge data into a tidygraph object for tidy network
analysis. This allows using dplyr verbs directly on graph data.

## Usage

``` r
as_tidygraph(edges, sector = NULL, directed = TRUE, add_node_attrs = TRUE)
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

  Logical; if TRUE (default), adds node-level attributes.

## Value

A tidygraph \`tbl_graph\` object that can be manipulated with dplyr
verbs and visualized with ggraph.

## Details

This function requires the tidygraph package to be installed. The
tidygraph framework allows you to use familiar dplyr verbs (\`filter\`,
\`mutate\`, \`select\`, etc.) on both nodes and edges of the graph.

Use \`activate(nodes)\` or \`activate(edges)\` to switch between
manipulating nodes and edges.

## See also

\[as_igraph()\] for igraph conversion

## Examples

``` r
if (FALSE) { # \dontrun{
edges <- load_unvalidated_promotions("edges", "~/cmap_data/promotions/unvalidated")

# Convert to tidygraph
g <- as_tidygraph(edges)

# Tidy network analysis
library(tidygraph)
library(dplyr)

# Find most central titles
g |>
  activate(nodes) |>
  mutate(centrality = centrality_pagerank()) |>
  arrange(desc(centrality)) |>
  as_tibble() |>
  head(10)

# Filter edges by frequency
g |>
  activate(edges) |>
  filter(frequency > 100)

# Visualize with ggraph
library(ggraph)
g |>
  activate(nodes) |>
  mutate(centrality = centrality_pagerank()) |>
  filter(centrality > 0.001) |>
  ggraph(layout = "fr") +
  geom_edge_link(alpha = 0.2) +
  geom_node_point(aes(size = centrality)) +
  geom_node_text(aes(label = name), repel = TRUE, size = 2)
} # }
```
