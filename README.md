# cmapr

**cmapr** is a R package for reproducible analysis of the [CMap Career Mobility Dataset](https://zenodo.org/records/15260189).

It provides a tidy interface for accessing, manipulating, and exploring large-scale career transition data—including job title mappings, specialization metrics, and validated/unvalidated promotion networks—enabling advanced labor market analysis, workforce research, and mobility modeling.

---

## Key Features

- **Seamless Data Access:**  
  Download and prepare the official CMap dataset from Zenodo with a single function call.

- **Title Mapping & Specialization:**  
  Explore sector-specific job title frequencies, specialization scores (SI), ONET codes, and title standardization steps (cleaned, generalized, simplified).

- **Career Mobility Networks:**  
  Analyze validated and statistically inferred job promotions as directed graphs, including edge and node properties and interactive HTML visualizations.

- **Tidyverse-First API:**  
  All functions return tibbles or lists of tibbles, designed for use with `dplyr`, `tidyr`, `ggplot2`, and the broader tidyverse.

---

## Installation

Install the latest version from GitHub:

```r
install.packages("remotes") # if needed
remotes::install_github("farach/cmapr")
```

---

## Data Access

The full CMap dataset is **not shipped** with this package due to size and licensing.  
To download and prepare the data (requires ~130MB disk space):

```r
library(cmapr)
# Download and unzip dataset from Zenodo (to a permanent location recommended)
dataset_dir <- download_cmap_data("~/cmap_data")
```
- By default, downloads to a temporary directory.  
- If data already exists, the function will let you know and skip re-download unless you set `overwrite = TRUE`.

---

## Typical Workflow & Usage Examples

### 1. Load Core Data

```r
result <- load_cmap_data(base_path = dataset_dir)
model_data <- result$model_data
metadata <- result$metadata
```

### 2. Explore Job Title Specialization

```r
si_data <- load_sector_specialization(file.path(dataset_dir, "titles/si"))
si_data |> 
  group_by(sector) |> 
  arrange(desc(si)) |> 
  slice_head(n = 10)
```

### 3. Job Title Mapping Pipeline

```r
title_map <- load_title_map(file.path(dataset_dir, "titles/map"))
title_map |> 
  count(sector, title_simplified, sort = TRUE)
```

### 4. Validated & Unvalidated Promotions Networks

#### Validated (human-annotated)

```r
validated_edges <- load_validated_promotions("edges", file.path(dataset_dir, "promotions/validated"))
validated_nodes <- load_validated_promotions("nodes", file.path(dataset_dir, "promotions/validated"))
# Open interactive HTML network for a sector/country
load_validated_promotions("network", file.path(dataset_dir, "promotions/validated"), open_html = "US_finance.html")
```

#### Unvalidated (model-inferred)

```r
unvalidated_edges <- load_unvalidated_promotions("edges", file.path(dataset_dir, "promotions/unvalidated"))
unvalidated_nodes <- load_unvalidated_promotions("nodes", file.path(dataset_dir, "promotions/unvalidated"))
# Open interactive HTML network for a sector/region
load_unvalidated_promotions("network", file.path(dataset_dir, "promotions/unvalidated"), open_html = "EUROPE_finance.html")
```

---

## Citation

Subhani et al. (2025), ["A global career mobility map from 170 million job transitions"](https://www.nature.com/articles/s41597-025-05526-3), *Scientific Data*, Nature.

---

## License

MIT © Alex Farach