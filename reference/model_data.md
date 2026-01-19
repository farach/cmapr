# CMap Career Mobility Data

A processed tibble containing job transition and specialization features
derived from the CMap dataset, as described in Subhani, S., Memon, S.A.,
& AlShebli, B. (2025). CMap: a database for mapping job titles, sector
specialization, and promotions across 24 sectors. \*Scientific Data,
12\*, 1214.
[doi:10.1038/s41597-025-05526-3](https://doi.org/10.1038/s41597-025-05526-3)

## Usage

``` r
model_data
```

## Format

A tibble with N rows and M columns. Main columns include:

- job_title_from:

  Source job title for the transition.

- job_title_to:

  Destination job title for the transition.

- transition_count:

  Number of observed transitions between these job titles.

- job_count_in_sector:

  Count of job appearances within sector specialization.

- transition_weighted_count:

  Weighted or normalized count of job-to-job transitions.

- job_weighted_count_in_sector:

  Weighted count of job title occurrences in sector index.

- promotion_probability:

  Estimated probability of promotion for this transition (0 to 1).

- region:

  Region where the transition occurred.

- sector:

  Sector code or name.

- validated:

  Indicator whether the transition is validated.

- si_from:

  Specialization Index for the source job.

- se_from:

  Sector Exclusivity for the source job.

- sd_from:

  Sector Dominance for the source job.

- weighted_freq_from:

  Weighted frequency of the source job.

- si_to:

  Specialization Index for the destination job.

- se_to:

  Sector Exclusivity for the destination job.

- sd_to:

  Sector Dominance for the destination job.

- weighted_freq_to:

  Weighted frequency of the destination job.

- si_difference:

  Change in specialization index (destination - source).

- sd_difference:

  Change in sector dominance (destination - source).

- popularity_difference:

  Change in weighted frequency (destination - source).

- education_progression_score:

  Score for educational progression.

- job_start_score:

  Score for starting a new job.

- upward_mobility:

  Binary indicator for upward mobility (high promotion probability).

- career_stagnation:

  Binary indicator for career stagnation (low promotion probability).

- job_hopping_potential:

  Binary indicator if the transition suggests high job hopping.

- source_file:

  File path of the source data.

## Source

<https://zenodo.org/records/15260189>

## Details

This dataset enables tidy analysis of career transitions, sector
specialization, and promotion probabilities, supporting research and
modeling with the tidyverse.
