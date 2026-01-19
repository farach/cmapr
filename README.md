# cmapr

**cmapr** is an R package for reproducible analysis of the [CMap Career Mobility Dataset](https://zenodo.org/records/15260189), a global database of standardized job titles, specialization scores, and career transitions across 24 sectors.

The package provides a tidy interface for accessing, manipulating, and exploring career mobility data—including job title mappings, specialization metrics, and validated or model-inferred promotion networks—enabling large-scale labor market analysis, workforce research, and mobility modeling.

------------------------------------------------------------------------

## 🔍 Key Features

-   **Standardized Title Taxonomy**\
    Access a multi-level title hierarchy based on over 5.2 million job titles from 220+ million public CVs. Titles are cleaned, generalized, and simplified across 24 industry sectors using NLP and LLM-assisted methods.

-   **Specialization Index (SI)**\
    Evaluate how concentrated a job title is within a sector using a normalized specialization score (0 to 1). High SI values denote strong occupational identity or niche expertise.

-   **Promotion Networks**\
    Explore two types of directed career transition graphs:\
    ▸ **Validated:** \~32,000 human-annotated promotions (U.S. and U.K.)\
    ▸ **Unvalidated:** \~61,000 model-inferred transitions from \~10 million CVs (global)\
    Graphs include edge weights, validation status, and optional interactive HTML views.

-   **Career Path Analysis**\
    Discover promotion paths between job titles with `find_career_paths()` and explore career ladders from any starting position with `career_ladder()`.

-   **Network Analysis Integration**\
    Convert promotion data to igraph or tidygraph objects with `as_igraph()` and `as_tidygraph()` for advanced network analysis, centrality measures, and visualization with ggraph.

-   **Tidyverse-First API**\
    All functions return `tibble` objects or lists of tibbles, designed to work fluidly with `dplyr`, `tidyr`, `ggplot2`, and the broader tidyverse ecosystem.

-   **Built-In Downloaders & Utilities**\
    Automatically download and unzip the latest official release from Zenodo, with functions to load structured files, parse career transitions, and join metadata.

------------------------------------------------------------------------

## 📦 Installation

Install the latest development version from GitHub:

``` r
install.packages("remotes")  # if needed
remotes::install_github("farach/cmapr")
```

------------------------------------------------------------------------

## 🗂️ Data Access

The full CMap dataset is **not shipped** with this package due to size and licensing. To download and prepare the data (requires \~130MB disk space):

``` r
library(cmapr)

# Download and unzip dataset from Zenodo (to a permanent location recommended)
dataset_dir <- download_cmap_data("~/cmap_data")
```

Notes:

-   By default, downloads to a temporary directory.
-   If data already exists, the function will let you know and skip re-download unless you set `overwrite = TRUE`.

------------------------------------------------------------------------

## 🧪 Typical Workflow & Usage Examples

### 1. Load Core Data

``` r
library(cmapr)
library(dplyr)

result <- load_cmap_data(base_path = dataset_dir)
model_data <- result$model_data
metadata <- result$metadata
```

### 2. Explore Job Title Specialization

``` r
si_data <- load_sector_specialization(file.path(dataset_dir, "titles/si"))

# Top specialized titles per sector
si_data |>
  group_by(sector) |>
  arrange(desc(si)) |>
  slice_head(n = 10)
```

### 3. Job Title Mapping Pipeline

``` r
# Fast load (default) - uses vroom, skips derived features
title_map <- load_title_map(file.path(dataset_dir, "titles/map"))

# Load with derived features (slower - adds title_type, word counts, etc.)
title_map_features <- load_title_map(
  file.path(dataset_dir, "titles/map"),
  add_features = TRUE
)

# Load only specific sectors (much faster for targeted analysis)
tech_titles <- load_title_map(
  file.path(dataset_dir, "titles/map"),
  sector_filter = "Information Technology"
)

# Count titles by sector
title_map |>
  count(sector, title_cleaned, sort = TRUE)
```

### 4. Validated & Unvalidated Promotions Networks

#### Validated (human-annotated)

``` r
# Load with readr (default)
validated_edges <- load_validated_promotions("edges", file.path(dataset_dir, "promotions/validated"))

# Or use vroom for faster loading
validated_edges <- load_validated_promotions("edges", file.path(dataset_dir, "promotions/validated"), reader = "vroom")

validated_nodes <- load_validated_promotions("nodes", file.path(dataset_dir, "promotions/validated"))

# List available network visualizations
networks <- load_validated_promotions("network", file.path(dataset_dir, "promotions/validated"))
print(networks)

# Open interactive HTML network for a sector/country
load_validated_promotions("network", file.path(dataset_dir, "promotions/validated"), open_html = "US_finance.html")
```

#### Unvalidated (model-inferred)

``` r
unvalidated_edges <- load_unvalidated_promotions("edges", file.path(dataset_dir, "promotions/unvalidated"))

unvalidated_nodes <- load_unvalidated_promotions("nodes", file.path(dataset_dir, "promotions/unvalidated"))

# Open interactive HTML network for a sector/region
load_unvalidated_promotions("network", file.path(dataset_dir, "promotions/unvalidated"), open_html = "EUROPE_finance.html")
```

### 5. Data Summarization & Analysis

``` r
# Summarize transitions by sector and region (using model_data)
summary <- summarize_transitions(model_data, by = c("sector", "region"))

# Get top transitions per sector
top_10 <- top_transitions(model_data, by = "sector", n = 10)

# Calculate promotion rates from validated edges
# Note: validated_edges uses "country_binned" not "region"
rates <- promotion_rate(validated_edges, by = c("sector", "country_binned"))

# Generate sector profiles
profiles <- sector_profile(model_data, by = "sector")

# Analyze title frequencies
title_freq <- title_frequency(title_map, by = "sector", n = 20)
```

### 6. Career Path Analysis

``` r
# Find all paths from "analyst" to "director"
paths <- find_career_paths(
  validated_edges,
  from = "analyst",
  to = "director",
  max_depth = 5
)
print(paths$summary)

# Explore career ladder from a starting title
ladder <- career_ladder(
  unvalidated_edges,
  start_title = "software engineer",
  depth = 4,
  sector = "Information Technology"
)
print(ladder$ladder)
```

### 7. Network Analysis with igraph/tidygraph

``` r
# Convert to igraph for network analysis
library(igraph)
g <- as_igraph(validated_edges, sector = "Accounting & Legal")

# Basic metrics
vcount(g)  # number of job titles
ecount(g)  # number of transitions
diameter(g)  # longest shortest path

# Find most central titles (PageRank)
pr <- page_rank(g)$vector
head(sort(pr, decreasing = TRUE), 10)

# Convert to tidygraph for tidy network analysis
library(tidygraph)
library(dplyr)

tg <- as_tidygraph(unvalidated_edges)

tg |>
  activate(nodes) |>
  mutate(centrality = centrality_pagerank()) |>
  arrange(desc(centrality)) |>
  as_tibble() |>
  head(10)

# Get network summary statistics
network_summary(validated_edges, sector = "healthcare")
```

------------------------------------------------------------------------

## 📘About the Dataset

The CMap dataset was constructed by aggregating over **546 million job experiences** from **220+ million publicly available CVs**, covering **197 countries** and **24 sectors** (e.g., health, finance, manufacturing). Job titles were cleaned and standardized into \~123,000 unique entries using large language models and multi-stage NLP pipelines.

-   **Specialization Index (SI):**\
    A numerical indicator (0–1) quantifying how sector-specific a job title is. Higher values indicate narrower occupational focus.

-   **Career Mobility Data:**

```         
-   \~32k human-labeled promotions (U.S. and U.K.)

-   \~61k statistically inferred transitions using a model trained on validated pairs

-   Model performance: **97.5% balanced accuracy**, **98.9% precision**, **99.2% recall**
```

------------------------------------------------------------------------

## 📖Citation

> Subhani, S., Memon, S.A. & AlShebli, B. [CMap: a database for mapping job titles, sector specialization, and promotions across 24 sectors](https://www.nature.com/articles/s41597-025-05526-3). Sci Data 12, 1214 (2025). <https://doi.org/10.1038/s41597-025-05526-3>

------------------------------------------------------------------------

## License

MIT © Alex Farach
