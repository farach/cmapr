#' CMap Career Mobility Data
#'
#' A processed tibble containing job transition and specialization features derived from the CMap dataset,
#' as described in Subhani, S., Memon, S.A., & AlShebli, B. (2025). CMap: a database for mapping job titles, sector specialization, and promotions across 24 sectors. *Scientific Data, 12*, 1214. \doi{10.1038/s41597-025-05526-3}
#'
#' This dataset enables tidy analysis of career transitions, sector specialization, and promotion probabilities, supporting research and modeling with the tidyverse.
#'
#' @format A tibble with N rows and M columns. Main columns include:
#' \describe{
#'   \item{job_title_from}{Source job title for the transition.}
#'   \item{job_title_to}{Destination job title for the transition.}
#'   \item{transition_count}{Number of observed transitions between these job titles.}
#'   \item{job_count_in_sector}{Count of job appearances within sector specialization.}
#'   \item{transition_weighted_count}{Weighted or normalized count of job-to-job transitions.}
#'   \item{job_weighted_count_in_sector}{Weighted count of job title occurrences in sector index.}
#'   \item{promotion_probability}{Estimated probability of promotion for this transition (0 to 1).}
#'   \item{region}{Region where the transition occurred.}
#'   \item{sector}{Sector code or name.}
#'   \item{validated}{Indicator whether the transition is validated.}
#'   \item{si_from}{Specialization Index for the source job.}
#'   \item{se_from}{Sector Exclusivity for the source job.}
#'   \item{sd_from}{Sector Dominance for the source job.}
#'   \item{weighted_freq_from}{Weighted frequency of the source job.}
#'   \item{si_to}{Specialization Index for the destination job.}
#'   \item{se_to}{Sector Exclusivity for the destination job.}
#'   \item{sd_to}{Sector Dominance for the destination job.}
#'   \item{weighted_freq_to}{Weighted frequency of the destination job.}
#'   \item{si_difference}{Change in specialization index (destination - source).}
#'   \item{sd_difference}{Change in sector dominance (destination - source).}
#'   \item{popularity_difference}{Change in weighted frequency (destination - source).}
#'   \item{education_progression_score}{Score for educational progression.}
#'   \item{job_start_score}{Score for starting a new job.}
#'   \item{upward_mobility}{Binary indicator for upward mobility (high promotion probability).}
#'   \item{career_stagnation}{Binary indicator for career stagnation (low promotion probability).}
#'   \item{job_hopping_potential}{Binary indicator if the transition suggests high job hopping.}
#'   \item{source_file}{File path of the source data.}
#' }
#' @source \url{https://zenodo.org/records/15260189}
"model_data"
