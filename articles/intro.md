# Get Started with cmapr

## **Introduction**

**cmapr** is a modern R package for tidy, reproducible analysis of the
[CMap Career Mobility Dataset](https://zenodo.org/records/15260189)—the
largest open research dataset of global career transitions, created for
the study [“A global career mobility map from 170 million job
transitions”](https://www.nature.com/articles/s41597-025-05526-3)
published in *Scientific Data* (Nature).

The CMap dataset provides anonymized, aggregated records of **170
million real-world job transitions** across countries, sectors, and job
titles. It includes standardized mappings of job titles, sector and
regional labels, specialization indices, and directed promotion
networks, enabling powerful labor market research and modeling.

**cmapr** makes it easy to access, manipulate, and analyze this data
using the tidyverse ecosystem.

------------------------------------------------------------------------

### **Installation**

Install from GitHub using `remotes`:

``` r
install.packages("remotes")
remotes::install_github("farach/cmapr")
```

------------------------------------------------------------------------

### **Downloading the Data**

The full CMap dataset (~130MB) is **not bundled** with cmapr due to size
and licensing. Instead, you can download the official release directly
from Zenodo.

**Tip:** Choose a permanent folder for the data so you only need to
download it once. For example, use `"~/cmap_data"` (your home
directory), or a project-specific path.

``` r
library(cmapr)
dataset_dir <- download_cmap_data("~/cmap_data")
```

- The function will download and unzip the data.

- If the data already exists, it will skip re-downloading by default.

- To **force overwrite/download**, set `overwrite = TRUE`:

``` r
dataset_dir <- download_cmap_data("~/cmap_data", overwrite = TRUE)
```

- Once downloaded, you can re-use this folder for all your analyses.

**Efficient Data Management:**

- Store data in a location that’s backed up and easily accessible for
  all your R projects.

- On shared or cloud systems, consider a workspace directory or mounted
  drive.

- If you use RStudio projects, you may want to keep `"cmap_data"`
  outside your main package folder to avoid accidental deletion.

------------------------------------------------------------------------

### **Loading and Exploring the Data**

After downloading, load the data into tidy tibbles for analysis:

``` r
result <- load_cmap_data(base_path = dataset_dir)
model_data <- result$model_data      # Main transitions and features
metadata   <- result$metadata        # Job title and sector metadata
```

You now have instant access to the core CMap tables, ready for use with
dplyr, tidyr, and ggplot2.

#### **Advanced Loading Options**

The loader functions support additional options for performance and
customization:

``` r
# Load title maps with custom options
title_map <- load_title_map(
  file.path(dataset_dir, "titles/map"),
  clean = TRUE,      # Standardize column names (default)
  reader = "vroom"   # Use vroom for faster loading
)

# Load validated promotions with vroom
validated_edges <- load_validated_promotions(
  "edges",
  file.path(dataset_dir, "promotions/validated"),
  reader = "vroom"
)
```

#### **Data Summarization**

Use the built-in summarizer functions to quickly analyze the data:

``` r
# Summarize transitions by sector
sector_summary <- summarize_transitions(model_data, by = "sector")

# Get top 10 transitions per sector
top_moves <- top_transitions(model_data, by = "sector", n = 10)

# Generate sector profiles
profiles <- sector_profile(model_data)

# Analyze title frequencies
title_freq <- title_frequency(title_map, by = "sector", n = 20)
```

------------------------------------------------------------------------

### **Next Steps**

See the next article for practical examples of data exploration with
cmapr!
