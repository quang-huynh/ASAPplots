#' Plot catch curves for catch
#' 
#' Creates catch curves to estimate Z from catch data. Useful???
#' @param asap name of the variable that read in the asap.rdat file
#' @param a1 list file produced by grab.aux.files function
#' @param save.plots save individual plots
#' @param od output directory for plots and csv files 
#' @param plotf type of plot to save
#' @param first.age youngest age to use in catch curve, -999 finds peak age (defaults to -999)
#' @export

PlotCatchCurvesForCatch <- function(asap,a1,save.plots,od,plotf,first.age=-999){
  # create catch curve plots for catch by fleet
  usr <- par("usr"); on.exit(par(usr))
  par(oma=c(1,1,1,1),mar=c(4,4,1,0.5))
  cohort <- seq(asap$parms$styr-asap$parms$nages-1, asap$parms$endyr+asap$parms$nages-1)
  ages <- seq(1,asap$parms$nages)
  my.col <- rep(c("blue","red","green","orange","gray50"),50)
  for (ifleet in 1:asap$parms$nfleets){
    if (asap$parms$nfleets == 1) title1 = "Catch"
    if (asap$parms$nfleets >= 2) title1 = paste0("Catch for Fleet ",ifleet)
    
    # set up full age range matrices
    catch.comp.mat.ob <- matrix(0, nrow=asap$parms$nyears, ncol=asap$parms$nages)
    catch.comp.mat.pr <- matrix(0, nrow=asap$parms$nyears, ncol=asap$parms$nages)
    
    # determine age range for fleet and fill in appropriate ages
    age1 <- asap$fleet.sel.start.age[ifleet]
    age2 <- asap$fleet.sel.end.age[ifleet]
    catch.comp.mat.ob[,age1:age2] <- asap$catch.comp.mats[[(ifleet*4-3)]]
    catch.comp.mat.pr[,age1:age2] <- asap$catch.comp.mats[[(ifleet*4-2)]]
    
    # get catch at age
    catchob <- wtprop2caa(asap$catch.obs[ifleet,],  asap$WAA.mats[[(ifleet*2-1)]], catch.comp.mat.ob)
    catchpr <- wtprop2caa(asap$catch.pred[ifleet,], asap$WAA.mats[[(ifleet*2-1)]], catch.comp.mat.pr)
    
    # replace zeros with NA and take logs
    cob <- rep0log(catchob)
    cpr <- rep0log(catchpr)
    
    # make cohorts
    cob.coh <- makecohorts(cob)
    cpr.coh <- makecohorts(cpr)
    
    # drop plus group
    cob.coh[,asap$parms$nages] <- NA
    cpr.coh[,asap$parms$nages] <- NA
    
    first.age.label <- 1
    if (first.age==1) title1 <- paste0(title1," First Age = 1") 
    
    # determine which ages to use for each cohort (default)
    if (first.age == -999){
      cob.coh <- find_peak_age(cob.coh)
      cpr.coh <- find_peak_age(cpr.coh)
      first.age.label <- "find_peak"
      title1 <- paste0(title1," (Peak Age)")       
    }
    
    # or drop youngest ages based on user control
    if (first.age > 1) {
      cob.coh[,1:(first.age-1)] <- NA
      cpr.coh[,1:(first.age-1)] <- NA
      title1 <- paste0(title1," First Age = ",first.age)
      first.age.label <- first.age
    }
    
    # compute Z by cohort
    z.ob <- calc_Z_cohort(cob.coh)
    z.pr <- calc_Z_cohort(cpr.coh)
    
    # make the plots
    par(mfrow=c(2,1))
    plot(cohort,cohort,type='n',ylim=range(c(cob.coh,cpr.coh,0),na.rm=T),xlab="",ylab="Log(Catch)",main=paste0(title1," Observed"))
    for (i in 1:length(cob.coh[,1])){
      lines(seq(cohort[i],cohort[i]+asap$parms$nages-1),cob.coh[i,],type='p',lty=1,pch=seq(1,asap$parms$nages),col="gray50")
      lines(seq(cohort[i],cohort[i]+asap$parms$nages-1),cob.coh[i,],type='l',lty=1,col=my.col[i])
    }
    
    Hmisc::errbar(cohort,z.ob[,1],z.ob[,3],z.ob[,2],xlab="Year Class",ylab="Z",ylim=range(c(z.ob,z.pr,0),na.rm=T))
    
    if (save.plots) savePlot(paste0(od,"catch_curve_",title1,"_Observed_first_age_",first.age.label,".",plotf), type=plotf)
    
    plot(cohort,cohort,type='n',ylim=range(c(cob.coh,cpr.coh,0),na.rm=T),xlab="",ylab="Log(Catch)",main=paste0(title1," Predicted"))
    for (i in 1:length(cob.coh[,1])){
      lines(seq(cohort[i],cohort[i]+asap$parms$nages-1),cpr.coh[i,],type='p',lty=1,pch=seq(1,asap$parms$nages),col="gray50")
      lines(seq(cohort[i],cohort[i]+asap$parms$nages-1),cpr.coh[i,],type='l',lty=1,col=my.col[i])
    }
    
    Hmisc::errbar(cohort,z.pr[,1],z.pr[,3],z.pr[,2],xlab="Year Class",ylab="Z",ylim=range(c(z.ob,z.pr,0),na.rm=T))
    
    if (save.plots) savePlot(paste0(od,"catch_curve_",title1,"_Predicted_first_age_",first.age.label,".",plotf), type=plotf)
    
    
    # write out .csv files for Z, one file for each fleet
    asap.name <- a1$asap.name
    
    colnames(z.ob) <-c("Z.obs","low.80%", "high.80%")
    write.csv(z.ob, file=paste0(od,"Z.Ob.Fleet",ifleet,"_",asap.name,".csv"), row.names=cohort)
    
    colnames(z.pr) <-c("Z.pred","low.80%", "high.80%")
    write.csv(z.pr, file=paste0(od,"Z.Pr.Fleet.",ifleet,"_",asap.name,".csv"), row.names=cohort)
    
  }
  return()
}
