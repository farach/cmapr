# cmapr

Modern R package for reproducible analysis of the CMap Career Mobility Dataset

## Installation

Install the latest version from GitHub:

```r
# Install remotes if needed
install.packages("remotes")
# Install cmapr
remotes::install_github("yourusername/cmapr")
```

## Data Access

The full CMap dataset is **not shipped** with this package due to size.  
To download and prepare the data:

```r
library(cmapr)
# Download and unzip the dataset from Zenodo (~130MB)
dataset_dir <- download_cmap_data("~/cmap_data")
```

## Usage Example

Load and process CMap data:

```r
result <- load_cmap_data(base_path = dataset_dir)
model_data <- result$model_data
metadata <- result$metadata
```

Summarize mobility features:

```r
library(dplyr)
model_data |> 
  group_by(region, sector) |> 
  summarize(mean_promotion = mean(promotion_probability, na.rm = TRUE))
```

## Citation

Subhani et al. (2025), ["A global career mobility map from 170 million job transitions"](https://www.nature.com/articles/s41597-025-05526-3), *Scientific Data*, Nature.

## License

MIT © Alex Farach