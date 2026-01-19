# Global variables used in NSE contexts across the package
# Consolidated here to avoid R CMD check NOTEs

utils::globalVariables(c(

  # Common symbols
  ".", "n_rows",

  # cmap_loader.R - promotion data columns
  "job_title_from", "job_title_to",
  "frequency.x", "frequency.y",
  "weighted_frequency.x", "weighted_frequency.y",
  "si_to", "si_from", "se_to", "se_from", "sd_to", "sd_from",
  "weighted_freq_to", "weighted_freq_from",
  "promotion_probability", "region", "sector", "validated",

  # sector_specialization_loader.R - SI data columns
  "title", "frequency", "weighted_frequency", "se", "sd", "si",
  "onet_soc_codes", "title_type", "title_length", "title_word_count",

  # title_map_loader.R - title mapping columns
  "title_cleaned", "frequency_cleaned", "title_generalized",
  "title_cleaned_length", "title_similarity",

  # summarizers.R - summary function columns
  "total_weight", "n_transitions",

  # career_paths.R - career path analysis columns
  "to_title", "total_frequency", "n_sources", "level",
  "path_id", "path_length", "path",

  # graph_conversion.R - graph conversion columns
  "from", "to", "name", "centrality"
))
