# CMap Career Mobility Data Dictionary

| Column                       | Description                                                                                   |
|------------------------------|-----------------------------------------------------------------------------------------------|
| job_title_from               | Source job title for the transition                                                          |
| job_title_to                 | Destination job title for the transition                                                     |
| transition_count             | Number of times this job-to-job transition occurs in the raw promotion data                  |
| job_count_in_sector          | Number of times the job appears in the specialization index (sector-specific count)          |
| transition_weighted_count    | Weighted or normalized count of transitions from the promotions data                         |
| job_weighted_count_in_sector | Weighted or normalized count of job title occurrences in the specialization index            |
| promotion_probability        | Estimated probability of promotion for this job-to-job transition (0-1)                      |
| region                       | Region where the transition occurred                                                         |
| sector                       | Sector code or name for the job                                                              |
| validated                    | Indicator for whether the transition was validated                                           |
| si_from                      | Specialization Index for the source job                                                      |
| se_from                      | Sector Exclusivity for the source job                                                        |
| sd_from                      | Sector Dominance for the source job                                                          |
| weighted_freq_from           | Weighted frequency for the source job                                                        |
| si_to                        | Specialization Index for the destination job                                                 |
| se_to                        | Sector Exclusivity for the destination job                                                   |
| sd_to                        | Sector Dominance for the destination job                                                     |
| weighted_freq_to             | Weighted frequency for the destination job                                                   |
| si_difference                | Difference in specialization index (destination - source)                                    |
| sd_difference                | Difference in sector dominance (destination - source)                                        |
| popularity_difference        | Difference in weighted frequency (destination - source)                                      |
| education_progression_score  | Data-derived score for educational progression                                               |
| job_start_score              | Data-derived score for starting a new job                                                    |
| upward_mobility              | Indicator if the promotion probability is high (binary)                                      |
| career_stagnation            | Indicator if the promotion probability is low (binary)                                       |
| job_hopping_potential        | Indicator if the transition suggests high job hopping (binary)                               |
| source_file                  | File path of the source data                                                                 |

See [Nature paper](https://www.nature.com/articles/s41597-025-05526-3) and [Zenodo dataset](https://zenodo.org/records/15260189) for further details.