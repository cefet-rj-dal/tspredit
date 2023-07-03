python_env <- NULL

#'@import reticulate
.onLoad <- function(libname, pkgname) {
  python_env <<- new.env()

  reticulate::source_python(system.file("python", "ts_lstm.py", package = "daltoolboxext"), envir=python_env)
}


