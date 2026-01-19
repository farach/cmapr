# Download the CMap Career Mobility Dataset from Zenodo

Downloads and unzips the official CMap dataset as described in Subhani,
S., Memon, S.A. & AlShebli, B. CMap: a database for mapping job titles,
sector specialization, and promotions \#' across 24 sectors. Sci Data
12, 1214 (2025). https://doi.org/10.1038/s41597-025-05526-3. The dataset
is large and not shipped with the package; this function makes
reproducible access easy.

## Usage

``` r
download_cmap_data(dest_dir = tempdir(), overwrite = FALSE)
```

## Arguments

- dest_dir:

  Directory to save and unzip the dataset. Defaults to tempdir().

- overwrite:

  Logical; if TRUE, always re-download even if data exists. Defaults to
  FALSE.

## Value

Path to the unzipped dataset directory (usually dest_dir/dataset).

## Details

The dataset is downloaded from Zenodo at
https://zenodo.org/records/15260189. If the data is already present, the
function displays a message and skips download unless overwrite = TRUE.

## Examples

``` r
if (FALSE) { # \dontrun{
dataset_dir <- download_cmap_data("~/cmap_data")
# To force re-download:
dataset_dir <- download_cmap_data("~/cmap_data", overwrite = TRUE)
} # }
```
