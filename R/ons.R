

## START TODO - make these fns more general?
## Something like this (but this example doesn't work):
## ons_get_item_by <- function(df, name, value) {
##     df$items[df$items[name] %>% detect_index(~ . == value)]
## }

## TODO - fix weirdness here - should be able to df$items %>%
## filter(...) rather than this detect_index but some type confusion

##' @importFrom magrittr %>%
ons_item_by_id <- function(df, id) {
    df$items[df$items$id %>% purrr::detect_index(~ . == id), ]
}

##' @importFrom magrittr %>%
ons_edition_by_name <- function(df, edition) {
    df$items[df$items$edition %>% purrr::detect_index(~ . == edition), ]
}

##' @importFrom magrittr %>%
ons_version_by_version <- function(df, version) {
    df$items[df$items$version %>%  purrr::detect_index(~ . == version), ]
}

## END TODO - make these fns more general?

ons_download_by_format <- function(df, format) {
    df$downloads[[format]]
}

## TODO - is there a std fn for this?
##' @import logger
log_panic <- function(...) {
    logger::log_error(...)
    quit(status = 1)
}
##' Retrieves a dataframe describing the datasets available from ONS via the API.
##'
##' This returns a dataframe containing details that can be passed to other fns in this package for further processing
##' @title Datasets Setup
##' @return a dataframe describing available datasets
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
##' @import jsonlite
ons_datasets_setup <- function() {
    jsonlite::fromJSON("https://api.beta.ons.gov.uk/v1/datasets")
}

#' Retrieve the metadata for the given dataset.
#'
#' Makes calls to the ONS API and retrieves the metadata for the
#' datasets. The dataset selection can be refined via the edition and
#' version parameters
#'
#' @title Dataset By Id
#' @param df dataframe describing the dataset
#' @param id the identifier of the dataset
#' @param edition the edition of the dataset (if empty, select latest)
#' @param version the version of the dataset (if empty, select latest)
#' @return
#' @author Neale Swinnerton <neale@mastodonc.com>
#' @export
##' @importFrom magrittr %>%
##' @import logger
ons_dataset_by_id <- function(df, id, edition, version) {
    links <- ons_item_by_id(df, id)$links
    if (missing(edition)) {
        logger::log_info("Edition not specified, defaulting to  latest version")
        link <- links$latest_version$href
    } else {
        metadata <-
            jsonlite::fromJSON(links$editions$href) %>%
            ons_edition_by_name(edition)

        is_latest <- FALSE
        if (missing(version)) {
            logger::log_info("Version of ", edition,
                             " edition not specified, defaulting to latest version")
            link <- metadata$links$latest_version$href
            is_latest <- TRUE
        } else {
            version_metadata <-
                jsonlite::fromJSON(metadata$links$versions$href) %>%
                ons_version_by_version(version)

            if (nrow(version_metadata) == 0) {
                log_panic("Version ", version, " of ", edition,
                          " is not available")
            } else {
                logger::log_info("Version ", version, " of ", edition,
                                 " edition selected")
            }

            link <- version_metadata$links$self$href

            ## TODO should we work out whether the specified version is the latest here?
            ##      is 'latest' highest version or newest release-date ?
        }
    }

    logger::log_info(sprintf("Retrieving dataset metadata from %s", link))
    dataset <- jsonlite::fromJSON(link)
    dataset$is_latest <- is_latest

    dataset
}

##' Download
##'
##' \code{ons_download} retrieves the data described by the given df
##' @param df dataframe
##' @param filebase base of the filename to which the data should be downloaded
##' @param format a valid format for the download
##' @export
##' @importFrom magrittr %>%
##' @import logger

ons_download <- function(df, filebase, format="csv") {
    download <-
        df %>%
        ons_download_by_format(format)  ## TODO - error if format not found?

    validate_file <- function(f) {
        expected_size <- as.numeric(download$size)

        if (file.size(f) != expected_size) {
            log_panic(sprintf("Inconsistent file size expected %d, got %d",
                              expected_size,
                              file.size(f)))
            FALSE
        } else {
            TRUE
        }
    }

    logger::log_info(sprintf("Downloading data from %s", download$href))

    destfile <- here::here("data",
                           "original_data",
                           sprintf("%s.v%02d.%s",
                                   filebase, as.numeric(df$version), format))

    if (safe_download(url = c(download$href),
                      destfile = destfile,
                      fvalidate = validate_file)) {
        write_metadata(df, sprintf("%s.meta.json", destfile))
        logger::log_info(sprintf("File created at %s ", destfile))
    }

    if (df$is_latest) {
        linkfile <- here::here("data",
                               "original_data",
                               sprintf("%s.LATEST.%s", filebase, format))
        if (file.exists(linkfile)) {
            file.remove(linkfile)
        }

        file.symlink(destfile,
                     linkfile)
    }

    df
}
