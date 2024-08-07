% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/interpol.area.R
\name{interpol.area}
\alias{interpol.area}
\title{Interpolate missing intensities and calculate the area for a single EIC.}
\usage{
interpol.area(x, y, all.x, all.w)
}
\arguments{
\item{x}{the positions of x(retention time) where non-NA y is observed.}

\item{y}{the observed intensities.}

\item{all.x}{all possible x(retention time) in the LCMS profile.}

\item{all.w}{the "footprint" of each measured retention time, used as weight for the corresponding y.}
}
\value{
The area is returned.
}
\description{
This is an internal function.
}
