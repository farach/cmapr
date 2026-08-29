# Load Validated Promotions Data

Loads validated promotion data from the specified folder containing
sector/country-specific job movement CSVs. Supports loading "edges" (job
movements with validation metrics) and "nodes" (title frequencies per
sector/country). Optionally lists and opens sector/country network .html
files for interactive visualization.

## Usage

``` r
load_validated_promotions(
  subfolder = c("edges", "nodes", "network"),
  data_dir,
  open_html = NULL,
  reader = c("readr", "vroom")
)
```

## Arguments

- subfolder:

  Which subfolder to load: "edges", "nodes", or "network".

- data_dir:

  Path to root validated promotions directory (e.g.,
  "~/cmap_data/dataset/promotions/validated").

- open_html:

  Optional: name of .html file to open from the network folder (e.g.,
  "US_accounting_and_legal.html").

- reader:

  Character string specifying which CSV reader to use: "readr" (default)
  or "vroom".

## Value

For "edges" or "nodes": dataframe (tibble) with validated promotion
data. For "network": list of available HTML files (invisible if opening
one).

## Details

Edges: Promotion movements with validation metrics. Nodes: Job title
frequencies by sector/country. Network: Interactive HTML sector/country
visualization files. See README in the dataset for column details and
methodology.

## Examples

``` r
if (FALSE) { # \dontrun{
validated_dir <- "~/cmap_data/dataset/promotions/validated"

# Load all validated promotion edges (job movements)
validated_edges <- load_validated_promotions("edges", validated_dir)

# Load all validated title nodes
validated_nodes <- load_validated_promotions("nodes", validated_dir)

# List available network HTML files
validated_networks <- load_validated_promotions("network", validated_dir)

# Open a specific sector/country network visualization
load_validated_promotions(
  "network",
  validated_dir,
  open_html = "US_accounting_and_legal.html"
)
} # }
```
