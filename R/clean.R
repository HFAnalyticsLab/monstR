##' @title Create the MONSTR defaults
##' @param download_root Root of directory hierarchy.
##' @return an augmented metadata
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
##' @import here
monstr_pipeline_defaults <- function(download_root="") {
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
##'     extracted with \code{\link{monstr_data}}
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
##' @import readr
##' @import readxl
monstr_read_file <- function(metadata) {
    monstr <- metadata$monstr

    if (monstr$format == "csv") {
        metadata$monstr_data <- readr::read_csv(metadata$monstr$destfile)
    } else if (monstr$format %in% c("xls", "xlsx")) {
        metadata$monstr_data <- readxl::read_excel(metadata$monstr$destfile)
    }
    metadata$monstr <- monstr
    metadata
}

##' @title Clean the data according to MONSTR rules.
##' @param metadata description the downloaded file.
##' @return description of the cleaned data
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
##' @import janitor
monstr_clean <- function(metadata) {
    metadata$monstr_data <- janitor::clean_names(metadata$monstr_data)
    metadata$monstr$is_clean <- TRUE
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
monstr_data <- function(metadata) {
    metadata$monstr_data
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
##' @importFrom readr write_csv write_rds
##' @importFrom writexl write_xlsx
monstr_write_clean <- function(metadata,
                            format="csv",
                            create_directory=TRUE) {
    success <- TRUE
    monstr <- metadata$monstr

    if (monstr$is_clean) {

        data <- metadata$monstr_data
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
            success <- success && write_csv(data, monstr, create_directory)
        }

        if (xls) {
            success <- success && write_xlsx(data, monstr, create_directory)
        }

        if (rds) {
            success <- success && write_rds(data, monstr, create_directory)
        }
    } else {
        logger::log_warn("Data has not been cleaned. NOT writing")
        success <- FALSE
    }

    success
}
