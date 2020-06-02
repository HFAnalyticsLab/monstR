## requires libssl-dev & libcurl4-openssl-dev on Linux
## TODO - what is the equivalent on Windows?

install.packages(c("devtools",
                   "tidyverse",
                   "here",
                   "polite",
                   "janitor",
                   "jsonlite",
                   "logger",
                   "roxygen2"))

## TODO - probably not needed in the pipeline code, but we have it for
## now until refactoring complete.
devtools::install_github('THF-evaluative-analytics/THFstyle')
