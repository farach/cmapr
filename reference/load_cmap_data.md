# CMap Data Loader

Functions to load and prepare CMap data according to Subhani et al.
(2025): https://www.nature.com/articles/s41597-025-05526-3

## Usage

``` r
load_cmap_data(base_path, ext_path = NULL, output_path = NULL, verbose = TRUE)
```

## Arguments

- base_path:

  Path to the unzipped CMap dataset directory (e.g. as returned by
  [`download_cmap_data()`](https://farach.github.io/cmapr/reference/download_cmap_data.md)).

- ext_path:

  Path to extended dataset (if applicable).

- output_path:

  Path to save processed outputs (optional).

- verbose:

  Logical, print progress messages?

## Value

A list containing processed model_data and metadata.

## Details

All functions follow tidyverse idioms and use tibbles throughout.

The full dataset must be downloaded first with
[`download_cmap_data()`](https://farach.github.io/cmapr/reference/download_cmap_data.md).
Example:

      dataset_dir <- download_cmap_data("~/cmap_data")
      result <- load_cmap_data(base_path = dataset_dir)
