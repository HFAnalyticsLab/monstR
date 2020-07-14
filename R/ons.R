
api_base_url <- "https://api.beta.ons.gov.uk/v1/datasets"

## START TODO - make these fns more general?
## Something like this (but this example doesn't work):
## ons_get_item_by <- function(df, name, value) {
##     df$items[df$items[name] %>% detect_index(~ . == value)]
## }

## TODO - fix weirdness here - should be able to df$items %>%
## filter(...) rather than this detect_index but some type confusion


ons_item_by_id <- function(df, id) {
    df$items[df$items$id %>% purrr::detect_index(~ . == id), ]
}

ons_edition_by_name <- function(df, edition) {
    df$items[df$items$edition %>% purrr::detect_index(~ . == edition), ]
}

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

##' Make request to given url, which is assumed to be the ONS api.
##'
##' data retrieved is converted to tidyverse tibble if possible.
##'
##' @title Call the ONS API
##' @param url url to call @seeAlso \code{\link{[api_base_url]}}
##' @return a list contained the API call results
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @import dplyr
ons_api_call <- function(url) {
    df <- jsonlite::fromJSON(url)
    if ("items" %in% colnames(df)) {
        df$items <- dplyr::as_tibble(df$items)
    }
    df
}

##' Retrieves a dataframe describing the datasets available from ONS via the API.
##'
##' This returns a dataframe containing details that can be passed to
##' other fns in this package for further processing
##' @title Datasets Setup
##' @return a list describing available datasets
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
##' @import jsonlite
##' @import dplyr
##' @examples
##' \dontrun{
##' ons_datasets_setup(thf_pipeline_defaults()) # rooted in current project
##' }
##' \dontrun{
##' ons_datasets_setup(thf_pipeline_defaults(download_root="/path/to/download/root/"))
##' }
ons_datasets_setup <- function(defaults) {
    results <- ons_api_call(api_base_url)
    results$thf <- defaults
    results$thf$src_url <-  api_base_url

    results
}

##' @title Available Datasets
##' @return list of available datasets
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
##' @import dplyr
##' @examples 
#' \dontrun{
#' ons_available_datasets()
#' }
ons_available_datasets <- function() {
    ons_api_call(api_base_url)$items %>% dplyr::select(id)
}

#' Retrieve the metadata for the given dataset.
#'
#' Makes calls to the ONS API and retrieves the metadata for the
#' datasets. The dataset selection can be refined via the edition and
#' version parameters
#'
#' @title Dataset By Id
#' @param metadata data describing the dataset
#' @param id the identifier of the dataset. Valid values from \code{ons_available_datasets()}
#' @param edition the edition of the dataset (if empty, select latest). Valid values from \code{ons_available_editions(...)}
#' @param version the version of the dataset (if empty, select latest). Valid values from \code{ons_available_available(...)}
#' @return a dataframe describing the dataset.
#' @author Neale Swinnerton <neale@mastodonc.com>
#' @export
##' @import logger
ons_dataset_by_id <- function(metadata, id, edition, version) {
    links <- ons_item_by_id(metadata, id)$links
    if (missing(edition)) {
        logger::log_info("Edition not specified, defaulting to  latest version")
        link <- links$latest_version$href
        is_latest <- TRUE
    } else {
        metadata <-
            ons_api_call(links$editions$href) %>%
            ons_edition_by_name(edition)

        is_latest <- FALSE
        if (missing(version)) {
            logger::log_info("Version of ", edition,
                             " edition not specified, defaulting to latest version")
            link <- metadata$links$latest_version$href
            is_latest <- TRUE
        } else {
            version_metadata <-
                ons_api_call(metadata$links$versions$href) %>%
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
    dataset <- ons_api_call(link)

    dataset$thf <- metadata$thf
    dataset$thf$is_latest <- is_latest
    dataset$thf$datasource <- "ons"
    dataset$thf$dataset <- id
    dataset$thf$edition <- dataset$edition
    dataset$thf$version <- dataset$version
    dataset
}

##' @title Available Editions
##' @param id dataset identifier. Valid values from \code{ons_available_datasets(...)}
##' @return a list of edition identifiers
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
##' @import dplyr
##' @examples 
##' \dontrun{
#' ons_available_editions(id = 'mid-year-pop-est')
#' }
ons_available_editions <- function(id) {
    metadata <- ons_api_call(sprintf("%s/%s/editions", api_base_url, id))

    metadata$items %>%
        dplyr::select(matches("edition"))
}

##' @title Available Versions
##' @param id dataset identifier. Valid values from \code{ons_available_datasets(...)}
##' @param edition edition identifier. Valid values from \code{ons_available_editions(...)}
##' @return a list of version identifiers
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @export
##' @import dplyr
##' @examples 
#' \dontrun{
#'  ons_available_versions(id = "regional-gdp-by-quarter", edition = "time-series") 
#'  }
ons_available_versions <- function(id, edition) {
    metadata <- ons_api_call(sprintf("%s/%s/editions/%s/versions", api_base_url, id, edition))

    metadata$items %>%
        dplyr::select(version)
}

##' Download
##'
##' \code{ons_download} retrieves the data described by the given df
##' @param metadata data describing the download
##' @param format a valid format for the download
##' @export
##' @import logger
ons_download <- function(metadata,
                         format="csv" ) {
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
try (if(!(format %in% c('csv', 'xls'))) stop('Format not allowed'))
    download <-
        metadata %>%
        ons_download_by_format(format)  ## TODO - error if format not found?

    metadata$thf$format <- format

    logger::log_info(sprintf("Downloading data from %s", download$href))

    destfile <-  generate_download_filename(template=metadata$thf$download_filename_template,
                                            root=metadata$thf$download_root,
                                            data=metadata$thf)

    if (safe_download(url = c(download$href),
                      destfile = destfile,
                      fvalidate = validate_file)) {
        write_metadata(metadata, sprintf("%s.meta.json", destfile))
        logger::log_info(sprintf("File created at %s ", destfile))
    }

    if (metadata$thf$is_latest) {

        version <- metadata$thf$version
        metadata$thf$version <- "LATEST"

        linkfile <- generate_download_filename(template=metadata$thf$download_filename_template,
                                               root=metadata$thf$download_root,
                                               data=metadata$thf)

        metadata$thf$version <- version
        if (file.exists(linkfile)) {
            file.remove(linkfile)
        }

        file.symlink(destfile,
                     linkfile)
        log_info("Create symlink to LATEST file")
    }

    metadata$thf$destfile <- destfile
    metadata
}
