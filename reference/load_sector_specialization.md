# Load and Augment Sector-Specific Title Specialization Data

Reads all sector-specific CSV files from the \`titles/si\` folder and
combines them into a single tidy dataframe. Optionally adds NLP-derived
features and sector-level summary statistics.

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

If \`summarize = FALSE\`, a tibble of specialization data. If
\`summarize = TRUE\`, a list with:

- si_data:

  A tibble of the combined specialization data.

- sector_stats:

  A tibble of sector-level summary statistics.

## Details

Each file in \`si_dir\` should be named \`\<sector\>.csv\` and include
columns: title, frequency, weighted_frequency, SE, SD, SI,
onet_soc_codes. If a \`sector\` column is not present, it is derived
from the file name. See accompanying paper for metric methodology.

## Examples

``` r
si_dir <- tempfile("cmapr-si-")
dir.create(si_dir)
specialization <- data.frame(
  title = c("Software Engineer", "Engineering Manager"),
  frequency = c(120, 40),
  weighted_frequency = c(0.75, 0.25),
  SE = c(0.02, 0.03),
  SD = c(0.15, 0.20),
  SI = c(0.86, 0.61),
  onet_soc_codes = c("15-1252.00", "11-9041.00")
)
utils::write.csv(
  specialization,
  file.path(si_dir, "technology.csv"),
  row.names = FALSE
)

si_result <- load_sector_specialization(si_dir, summarize = TRUE)
si_result$sector_stats |>
  dplyr::arrange(dplyr::desc(mean_title_length))
#> # A tibble: 2 × 9
#>   sector     title_type mean_title_length top_title n_titles total_titles avg_si
#>   <chr>      <chr>                  <dbl> <chr>        <int>        <int>  <dbl>
#> 1 technology Managerial                19 Engineer…        1            1   0.61
#> 2 technology Technical                 17 Software…        1            1   0.86
#> # ℹ 2 more variables: avg_sd <dbl>, avg_se <dbl>

unlink(si_dir, recursive = TRUE)
```
