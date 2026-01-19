# cmapr Roadmap

This document outlines planned features and improvements for the cmapr
package. Contributions and feedback are welcome!

## Implemented Features (Current Release)

### Career Path Analysis

- **[`find_career_paths()`](https://farach.github.io/cmapr/reference/find_career_paths.md)** -
  Find all promotion paths between two job titles
- **[`career_ladder()`](https://farach.github.io/cmapr/reference/career_ladder.md)** -
  Discover common progression routes from a starting title

### Graph/Network Integration

- **[`as_igraph()`](https://farach.github.io/cmapr/reference/as_igraph.md)** -
  Convert promotion edges to igraph objects for network analysis
- **[`as_tidygraph()`](https://farach.github.io/cmapr/reference/as_tidygraph.md)** -
  Convert promotion edges to tidygraph objects for tidy network analysis

## Planned Features

### Title Search & Matching

- **`search_titles()`** - Fuzzy search across 123k+ unique job titles
- **`similar_titles()`** - Find similar titles based on text similarity
  or network proximity
- **`cross_sector_titles()`** - Find equivalent titles that exist across
  multiple sectors
- **`lookup_title_si()`** - Quick lookup of specialization index for any
  title

### Comparative Analysis

- **`compare_sectors()`** - Side-by-side comparison of career metrics
  across sectors
- **`sector_mobility_matrix()`** - Analyze cross-sector career movement
  patterns
- **`title_comparison()`** - Compare career trajectories for similar
  titles across regions

### Data Exploration

- **`cmap_summary()`** - One-function overview of loaded dataset
  structure and statistics
- **`validate_cmap_data()`** - Check data integrity and completeness
- **`available_sectors()`** - List all sectors with summary statistics

### Visualization Helpers

- **`plot_career_ladder()`** - Visualize promotion hierarchies as
  directed graphs
- **`plot_sector_comparison()`** - Comparative bar/radar charts for
  sectors
- **`plot_title_network()`** - Interactive network visualization of
  career transitions

### Advanced Analytics

- **`promotion_probability()`** - Calculate transition probabilities
  between titles
- **`career_velocity()`** - Analyze speed of career progression by
  sector/region
- **`bottleneck_titles()`** - Identify titles that serve as career
  progression bottlenecks
- **`emerging_titles()`** - Detect titles with growing specialization or
  frequency

## Contributing

We welcome contributions! If you’d like to implement any of these
features:

1.  Open an issue to discuss the approach
2.  Fork the repository
3.  Create a feature branch
4.  Submit a pull request

For questions or suggestions, please open an issue on GitHub.

## Research Applications

The CMap dataset enables research in:

- **Labor Economics**: Wage progression, skill premiums, sector dynamics
- **Organizational Behavior**: Career development patterns, promotion
  structures
- **HR Analytics**: Talent pipeline analysis, succession planning
- **Education Policy**: Skills-to-jobs mapping, credential value
  analysis
- **Urban Economics**: Regional labor market differences, geographic
  mobility

See the [CMap paper](https://www.nature.com/articles/s41597-025-05526-3)
for methodology details.
