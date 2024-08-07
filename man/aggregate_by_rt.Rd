% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aggregate_by_rt.R
\name{aggregate_by_rt}
\alias{aggregate_by_rt}
\title{Aggregate the intensities and select median mz for features with identical rt.}
\usage{
aggregate_by_rt(features)
}
\arguments{
\item{features}{dataframe of retention time, m/z ratio, signal strength.}
}
\value{
returns a tibble with the following columns
\itemize{
  \item mz - m/z ratio
  \item rt - retention time
  \item intensities - signal strength
}
}
\description{
This functions computes median mz and sum of intensities over features with same rt.
}
