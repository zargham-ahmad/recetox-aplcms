% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/recover.weaker.R
\name{refine_selection}
\alias{refine_selection}
\title{Refine the selection based on mz and rt differences.}
\usage{
refine_selection(target_rt, rectangle, aligned_mz, rt_tol, mz_tol)
}
\arguments{
\item{target_rt}{float Target retention time value.}

\item{rectangle}{tibble Features with columns `rt` and `mz`.}

\item{aligned_mz}{float Mz value in the aligned feature table of the
feature to be recovered.}

\item{rt_tol}{float Retention time tolerance.}

\item{mz_tol}{float Mz tolerance to use.}
}
\value{
int Index of value in rectable closest to `target_rt` and `aligned_mz`.
}
\description{
Refine the selection based on mz and rt differences.
}
