# Get Path to Example Data

Returns the path to example data files included with the cmapr package.

## Usage

``` r
cmap_example_data(file = "example_transitions.csv")
```

## Arguments

- file:

  Character string specifying the example file name. Default is
  "example_transitions.csv".

## Value

Character string containing the full path to the example file, or an
empty string if the file does not exist.

## Examples

``` r
# Get path to example transitions data
example_path <- cmap_example_data()
if (nzchar(example_path)) {
  head(readr::read_csv(example_path))
}
#> Rows: 10 Columns: 7
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (4): sector, region, job_title_from, job_title_to
#> dbl (3): transition_weighted_count, si_from, si_to
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 6 × 7
#>   sector region job_title_from job_title_to transition_weighted_…¹ si_from si_to
#>   <chr>  <chr>  <chr>          <chr>                         <dbl>   <dbl> <dbl>
#> 1 Techn… North… Software Engi… Senior Soft…                   1250    0.85  0.88
#> 2 Techn… North… Senior Softwa… Engineering…                    890    0.88  0.72
#> 3 Techn… Europe Data Analyst   Data Scient…                    720    0.78  0.82
#> 4 Healt… North… Registered Nu… Nurse Manag…                    650    0.91  0.85
#> 5 Healt… Europe Medical Assis… Registered …                    580    0.75  0.91
#> 6 Finan… North… Financial Ana… Senior Fina…                    920    0.82  0.86
#> # ℹ abbreviated name: ¹​transition_weighted_count
```
