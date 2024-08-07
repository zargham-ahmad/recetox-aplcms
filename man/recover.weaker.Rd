% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/recover.weaker.R
\name{recover.weaker}
\alias{recover.weaker}
\title{Recover weak signals in some profiles that is not identified as a peak, but corresponds to identified peaks in other spectra.}
\usage{
recover.weaker(
  filename,
  sample_name,
  metadata_table,
  intensity_table,
  rt_table,
  mz_tol_relative,
  rt_tol_relative,
  extracted_features,
  adjusted_features,
  recover_mz_range,
  recover_rt_range,
  use_observed_range,
  mz_tol,
  min_bandwidth,
  max_bandwidth,
  bandwidth,
  recover_min_count,
  intensity_weighted
)
}
\arguments{
\item{filename}{the cdf file name from which weaker signal is to be recovered.}

\item{sample_name}{Name of the sample used for identification.}

\item{metadata_table}{Table containing metadata.}

\item{intensity_table}{Table containing intensities.}

\item{rt_table}{Table containing retention times.}

\item{mz_tol_relative}{the m/z tolerance used in the alignment.}

\item{rt_tol_relative}{the elution time tolerance in the alignment.}

\item{extracted_features}{The matrix which is the output from proc.to.feature().}

\item{adjusted_features}{The matrix which is the output from proc.to.feature().
The retention time in this object have been adjusted by the function adjust.time().}

\item{recover_mz_range}{The m/z around the feature m/z to search for observations.
The default value is NA, in which case 1.5 times the m/z tolerance in the aligned object will be used.}

\item{recover_rt_range}{The retention time around the feature retention time to search for observations.
The default value is NA, in which case 0.5 times the retention time tolerance in the aligned object will be used.}

\item{use_observed_range}{If the value is TRUE, the actual range of the observed locations
of the feature in all the spectra will be used.}

\item{mz_tol}{The mz.tol parameter provided to the remove_noise() function. This helps retrieve the intermediate file.}

\item{min_bandwidth}{The minimum bandwidth to use in the kernel smoother.}

\item{max_bandwidth}{The maximum bandwidth to use in the kernel smoother.}

\item{bandwidth}{A value between zero and one. Multiplying this value to the length of the signal along the
time axis helps determine the bandwidth in the kernel smoother used for peak identification.}

\item{recover_min_count}{minimum number of raw data points to support a recovery.}

\item{intensity_weighted}{Whether to use intensity to weight mass density estimation.}
}
\value{
Returns a list object with the following objects in it:
\itemize{
  \item aligned.ftrs - A matrix, with columns of m/z values, elution times, and signal strengths in each spectrum.
  \item pk.times - A matrix, with columns of m/z, median elution time, and elution times in each spectrum.
  \item mz.tol - The m/z tolerance in the aligned object.
  \item rt.tol - The elution time tolerance in the aligned object.
}
}
\description{
Given the aligned feature table, some features are identified in a subgroup of spectra. This doesn't mean they don't exist in the other spectra.
The signal could be too low to pass the run filter. Thus after obtaining the aligned feature table, this function re-analyzes each spectrum to
try and fill in the holes in the aligned feature table.
}
