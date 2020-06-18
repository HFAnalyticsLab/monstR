##' @title Apply THF defaults
##' @param df A 'base' setup, e.g. from \code{\link{ons_datasets_setup}}
##' @param download_root Root of directory hierarchy.
##' @return an augmented dataframe
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @import here
thf_pipeline_defaults <- function(df, download_root="") {
    basedir <- "{{download_root}}/data"
    filepath <- "{{datasource}}/{{dataset}}/{{edition}}/v-{{version}}.{{format}}"

    df$thf$download_filename_template = sprintf("%s/raw/%s",
                                                basedir,
                                                filepath)
    df$thf$clean_filename_template = sprintf("%s/clean/%s",
                                             basedir,
                                             filepath)
    if (missing(download_root)) {
        df$thf$download_root = here::here() # TODO here supposedly for
                                            # interactive use?
    }
    df
}

##' @title Read the file described by the df
##' @param df dataframe describing the downloaded file.
##' @return a df incorporating the data. The actually data can then be
##'     extracted with \code{\link{thf_data}}
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @import readr
##' @import readxl
thf_read_file <- function(df) {
    thf <- df$thf

    if (thf$format == "csv") {
        df$thf_data <- readr::read_csv(df$thf$destfile)
    } else if (thf$format %in% c("xls", "xlsx")) {
        df$thf_data <- readxl::read_excel(df$thf$destfile)
    }
    df$thf <- thf
    df
}

##' @title Clean the data according to THF rules.
##' @param df dataframe describing the downloaded file.
##' @return  a cleaned dataframe
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @import janitor
thf_clean <- function(df) {
    df$thf_data <- janitor::clean_names(df$thf_data)
    df$thf$is_clean <- TRUE
    df
}

##' Extract the tibble of the actual data
##'
##' @title Get the Data
##' @param df describing the downloaded data
##' @return a \code{\link[tibble]{dplyr::tibble}} of the data from the
##'     described download
##' @author Neale Swinnerton <neale@mastodonc.com>
thf_data <- function(df) {
    df$thf$data
}

##' @title Writes the data to the 'clean' area
##' @param df dataframe describing the data.
##' @param format any known format or "all" to save a copy as all
##'     known formats
##' @param create_directory boolean indicating whether directories
##'     should be created.
##' @return a boolean indicating success
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @import logger
##' @importFrom utils write.csv
##' @export

thf_write_clean <- function(df,
                            format="csv",
                            create_directory=TRUE) {
    success <- TRUE
    thf <- df$thf

    if (thf$is_clean) {

        data <- df$thf_data
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