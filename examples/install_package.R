library(devtools)

devtools::install_github("cefet-rj-dal/daLtoolbox", force=TRUE)
library(daLtoolbox)

devtools::install_github("cefet-rj-dal/daLtoolbox", force=TRUE, dep = FALSE, build_vignettes = TRUE)
library(daLtoolbox)
utils::browseVignettes()
