##' @title Create the THF defaults
##' @param download_root Root of directory hierarchy.
##' @return an augmented metadata
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
##' @import here
thf_pipeline_defaults <- function(download_root="") {
    basedir <- "{{download_root}}/data"
    filepath <- "{{datasource}}/{{dataset}}/{{edition}}/{{dataset}}-v{{version}}.{{format}}"

    metadata <- list()
    metadata$download_filename_template = sprintf("%s/raw/%s",
                                                basedir,
                                                filepath)
    metadata$clean_filename_template = sprintf("%s/clean/%s",
                                             basedir,
                                             filepath)
    if (missing(download_root)) {
        metadata$download_root = here::here() # TODO here supposedly for
                                            # interactive use?
    }
    metadata
}

##' @title Read the file described by the metadata
##' @param metadata description of the downloaded file.
##' @return a metadata incorporating the data. The actually data can then be
##'     extracted with \code{\link{thf_data}}
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
##' @import readr
##' @import readxl
thf_read_file <- function(metadata) {
    thf <- metadata$thf

    if (thf$format == "csv") {
        metadata$thf_data <- readr::read_csv(metadata$thf$destfile)
    } else if (thf$format %in% c("xls", "xlsx")) {
        metadata$thf_data <- readxl::read_excel(metadata$thf$destfile)
    }
    metadata$thf <- thf
    metadata
}

##' @title Clean the data according to THF rules.
##' @param metadata description the downloaded file.
##' @return description of the cleaned data
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
##' @import janitor
thf_clean <- function(metadata) {
    metadata$thf_data <- janitor::clean_names(metadata$thf_data)
    metadata$thf$is_clean <- TRUE
    metadata
}

##' Extract the tibble of the actual data
##'
##' @title Get the Data
##' @param metadata description of the downloaded data
##' @return a \code{\link[tibble]{dplyr::tibble}} of the data from the
##'     described download
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
thf_data <- function(metadata) {
    metadata$thf_data
}

##' @title Writes the data to the 'clean' area
##' @param metadata description of the data.
##' @param format any known format or "all" to save a copy as all
##'     known formats
##' @param create_directory boolean indicating whether directories
##'     should be created.
##' @return a boolean indicating success
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
##' @import logger
##' @importFrom utils write.csv
thf_write_clean <- function(metadata,
                            format="csv",
                            create_directory=TRUE) {
    success <- TRUE
    thf <- metadata$thf

    if (thf$is_clean) {

        data <- metadata$thf_data
        csv <- format == "csv"
        xls <- format %in% c("xls", "xlsx")
        rds <- format == "rds"

        if (format == "all") {
            csv <- TRUE
            xls <- TRUE
            rds <- TRUE
        }

        # TODO - should success be a logical vector indicating which
        # have succeeded?
        if (csv) {
            success <- success && write_csv(data, thf, create_directory)
        }

        if (xls) {
            success <- success && write_xlsx(data, thf, create_directory)
        }

        if (rds) {
            success <- success && write_rds(data, thf, create_directory)
        }
    } else {
        logger::log_warn("Data has not been cleaned. NOT writing")
        success <- FALSE
    }

    success
}
