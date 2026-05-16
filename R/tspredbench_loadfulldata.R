#' Load Full Dataset From Mini Data Object
#'
#' Downloads and loads the full `.RData` object referenced by `attr(x, "url")`
#' from a mini dataset object loaded from `data/`.
#'
#' @param x A mini dataset object that contains `attr(x, "url")`.
#' @return The full dataset object loaded from the remote `.RData` file.
#' @export
loadfulldata <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) {
    stop("The provided object does not contain attr(x, 'url').")
  }

  tf <- tempfile(fileext = ".RData")
  on.exit(unlink(tf), add = TRUE)

  utils::download.file(url, destfile = tf, mode = "wb", quiet = TRUE)
  e <- new.env(parent = emptyenv())
  obj_names <- load(tf, envir = e)

  if (length(obj_names) == 0) {
    stop(sprintf("No objects found in remote file: %s", url))
  }
  if (length(obj_names) > 1) {
    warning(sprintf("Remote file has multiple objects; returning first: %s", obj_names[1]))
  }

  get(obj_names[1], envir = e)
}

