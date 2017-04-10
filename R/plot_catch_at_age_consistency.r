#' Plot catch at age consistency
#' 
#' Lattice style plot of catch at age X vs age Y with each point a cohort for each fleet. Computed for both input and predicted catch at age.
#' @param asap name of the variable that read in the asap.rdat file
#' @param save.plots save individual plots
#' @param od output directory for plots and csv files 
#' @param plotf type of plot to save
#' @return list with correlation matrices for input and predicted catch at age matrices for each fleet
#' @export

PlotCatchAtAgeConsistency <- function(asap,save.plots,od,plotf){
  cat.corr <- list()
  for (ifleet in 1:asap$parms$nfleets){
    if (asap$parms$nfleets == 1) title1 = "Catch"
    if (asap$parms$nfleets >= 2) title1 = paste("Catch for Fleet ",ifleet, sep="")
    
    # get catch at age
    catchob <- wtprop2caa(asap$catch.obs[ifleet,],  asap$WAA.mats[[(ifleet*2-1)]], asap$catch.comp.mats[[(ifleet*4-3)]])
    catchpr <- wtprop2caa(asap$catch.pred[ifleet,], asap$WAA.mats[[(ifleet*2-1)]], asap$catch.comp.mats[[(ifleet*4-2)]])
    
    # replace zeros with NA and take logs
    cob <- rep0log(catchob)
    cpr <- rep0log(catchpr)
    
    # make cohorts
    cob.coh <- makecohorts(cob)
    cpr.coh <- makecohorts(cpr)
    
    # make the plots
    cob.cor <- PlotCoh(cob.coh,save.plots,od,plotf,mytitle=paste(title1," Observed", sep=""))
    cpr.cor <- PlotCoh(cpr.coh,save.plots,od,plotf,mytitle=paste(title1," Predicted", sep=""))
    cat.corr[[ifleet]] <- list(cob.cor,cpr.cor)
  }
  return(cat.corr)
}