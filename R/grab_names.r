#' Grab Names 
#' 
#' This function gets fleet and index names from the original ASAP.DAT file.
#' @param wd directory where ASAP run is located
#' @param asap.name Base name of original dat file (without the .dat extension)
#' @param asap name of the variable that read in the asap.rdat file
#' @return list of fleet names and index names
#' @export

GrabNames <- function(wd,asap.name,asap){
  my.names <- list()
  # in case the file was created outside the GUI
  my.names$fleet.names <- paste0("FLEET-",1:asap$parms$nfleets)
  my.names$index.names <- paste0("INDEX-",1:asap$parms$nindices)
  my.file.name <- paste0(wd, "\\", asap.name,".dat")
  if (file.exists(my.file.name)){
    datfile <- readLines(con = my.file.name)
    nlines <- length(datfile)
    nfinis <- nlines-asap$parms$nfleets-asap$parms$navailindices-3
    if (datfile[nfinis] == "###### FINIS ######"){
      my.names$fleet.names <- substr(datfile[(nfinis+2):(nfinis+2+asap$parms$nfleets-1)],3,100)
      avail.index.names <- substr(datfile[(nfinis+3+asap$parms$nfleets):(nlines-1)],3,100)
      my.names$index.names <- avail.index.names[asap$initial.guesses$index.use.flag==1]
    }  # end if-test for nfinis
  } # end if-test for dat file
  
  return(my.names)
}
