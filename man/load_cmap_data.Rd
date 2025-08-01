% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cmap_loader.R
\name{load_cmap_data}
\alias{load_cmap_data}
\title{CMap Data Loader}
\usage{
load_cmap_data(base_path, ext_path = NULL, output_path = NULL, verbose = TRUE)
}
\arguments{
\item{base_path}{Path to the unzipped CMap dataset directory (e.g. as returned by \code{download_cmap_data()}).}

\item{ext_path}{Path to extended dataset (if applicable).}

\item{output_path}{Path to save processed outputs (optional).}

\item{verbose}{Logical, print progress messages?}
}
\value{
A list containing processed model_data and metadata.
}
\description{
Functions to load and prepare CMap data according to
Subhani et al. (2025): https://www.nature.com/articles/s41597-025-05526-3
}
\details{
All functions follow tidyverse idioms and use tibbles throughout.


The full dataset must be downloaded first with \code{download_cmap_data()}.
Example:
\preformatted{
  dataset_dir <- download_cmap_data("~/cmap_data")
  result <- load_cmap_data(base_path = dataset_dir)
}
}
