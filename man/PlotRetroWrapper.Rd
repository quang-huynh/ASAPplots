% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/retrospective_functions.r
\name{PlotRetroWrapper}
\alias{PlotRetroWrapper}
\title{Plot retrospectives}
\usage{
PlotRetroWrapper(wd, asap.name, asap, save.plots, od, plotf)
}
\arguments{
\item{wd}{directory where ASAP run is located}

\item{asap.name}{Base name of original dat file (without the .dat extension)}

\item{asap}{name of the variable that read in the asap.rdat file}

\item{save.plots}{save individual plots}

\item{od}{output directory for plots and csv files}

\item{plotf}{type of plot to save}
}
\description{
Plots both standard and relative retrospectives and computes Mohn's rho values. Uses functions get.retro and plot.retro.
}
