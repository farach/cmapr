# Changelog

## cmapr (development version)

### Major Changes

- Modernized codebase to use native R pipe (`|>`) instead of magrittr
  (`%>%`)
- Updated to modern purrr patterns (`map() |> list_rbind()` instead of
  `map_dfr()`)
- Removed magrittr dependency
- Increased minimum R version to 4.1.0 (required for native pipe)

### New Features

- Added
  [`cmap_example_data()`](https://farach.github.io/cmapr/reference/cmap_example_data.md)
  function to access example data included with the package
- Added example transitions dataset for testing and demonstrations

#### Career Path Analysis

- Added
  [`find_career_paths()`](https://farach.github.io/cmapr/reference/find_career_paths.md)
  to discover promotion paths between two job titles
- Added
  [`career_ladder()`](https://farach.github.io/cmapr/reference/career_ladder.md)
  to explore common progressions from a starting title

#### Network Analysis Integration

- Added
  [`as_igraph()`](https://farach.github.io/cmapr/reference/as_igraph.md)
  to convert promotion edges to igraph objects
- Added
  [`as_tidygraph()`](https://farach.github.io/cmapr/reference/as_tidygraph.md)
  to convert promotion edges to tidygraph objects for tidy network
  analysis
- Added
  [`network_summary()`](https://farach.github.io/cmapr/reference/network_summary.md)
  to calculate common network metrics (density, centrality, components,
  diameter)

### Performance

- **Major optimization of
  [`load_title_map()`](https://farach.github.io/cmapr/reference/load_title_map.md)**:
  Reduced load time from 23+ minutes to seconds for default usage
  - Changed default reader from “readr” to “vroom” for faster file
    loading
  - Changed `add_features` default from TRUE to FALSE to skip expensive
    derived columns
  - Added `compute_similarity` parameter (default FALSE) to make
    similarity computation opt-in
  - Added early sector filtering before expensive operations
  - Vectorized Jaccard similarity computation with chunked processing

### Improvements

- Consolidated all `globalVariables` declarations in `zzz.R` for better
  maintainability
- Standardized error handling across all loader functions using
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
- Added comprehensive test suite with testthat
- Added GitHub Actions workflows for CI/CD:
  - R CMD check on multiple platforms
  - pkgdown site deployment
  - Test coverage reporting

### Bug Fixes

- Fixed incorrect package name reference in
  [`cmap_example_data()`](https://farach.github.io/cmapr/reference/cmap_example_data.md)
  (was “cmaploader”, now “cmapr”)
- Resolved NAMESPACE merge conflicts

### Documentation

- Improved roxygen documentation for all exported functions
