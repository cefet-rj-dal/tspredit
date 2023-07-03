## global reference to environment
#python_env <- NULL

#'@import reticulate
.onLoad <- function(libname, pkgname) {

  path <- system.file(package="daltoolboxext")
  reticulate::source_python(paste(path, "python/ts_lstm.py", sep="/"))
}


