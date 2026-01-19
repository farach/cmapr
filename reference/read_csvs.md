# Read and Row-Bind Multiple CSV Files

Reads multiple CSV files and combines them into a single tibble using
either readr or vroom.

## Usage

``` r
read_csvs(paths, reader = c("readr", "vroom"))
```

## Arguments

- paths:

  Character vector of file paths to read.

- reader:

  Character string specifying which CSV reader to use: "readr" (default)
  or "vroom".

## Value

A tibble containing all rows from the input CSV files.
