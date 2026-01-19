# Load and Augment Sector-Specific Title Specialization Data

Reads all sector-specific CSV files from the \`titles/si\` folder and
combines them into a single tidy dataframe. Adds NLP-derived features,
sector-level summary statistics, and a progress bar for user feedback.

## Usage

``` r
load_sector_specialization(
  si_dir,
  columns = NULL,
  sector_filter = NULL,
  add_nlp = TRUE,
  summarize = FALSE,
  verbose = TRUE
)
```

## Arguments

- si_dir:

  Path to the directory containing sector CSV files (e.g.,
  "~/cmap_data/titles/si").

- columns:

  Optional character vector of columns to select (default: NULL = all
  columns).

- sector_filter:

  Optional regex string to filter sectors (default: NULL = all sectors).

- add_nlp:

  Logical, add NLP-derived columns (title_type, title_length, etc.)?
  Default: TRUE.

- summarize:

  Logical, return sector-level summary statistics? Default: FALSE.

- verbose:

  Logical, print progress/messages? Default: TRUE.

## Value

A tibble with added variables and clean output, or a list if
summarize=TRUE.

## Details

Each file in \`si_dir\` must be named \`\<sector\>.csv\` and include
columns: sector, title, frequency, weighted_frequency, SE, SD, SI,
onet_soc_codes. The function now adds NLP-derived variables,
sector-level summaries, and a progress bar. See accompanying paper for
metric methodology.

## Examples

``` r
si_data <- load_sector_specialization("~/cmap_data/dataset/titles/si", add_nlp = TRUE, summarize = TRUE)
#> Error in load_sector_specialization("~/cmap_data/dataset/titles/si", add_nlp = TRUE,     summarize = TRUE): No CSV files found in ~/cmap_data/dataset/titles/si
si_data$sector_stats |> dplyr::arrange(dplyr::desc(mean_title_length))
#> Error: object 'si_data' not found
```
