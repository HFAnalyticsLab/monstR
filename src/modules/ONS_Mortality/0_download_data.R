library(curl)
library(rvest)  
library(polite)
library(stringr)
library(jsonlite)
library(purrr)
library(logger)

## START TODO - make these fns more general?
ons_item_by_id <- function(df, id) {
    df$items[df$items$id %>% detect_index(~ . == id),]
}

ons_edition_by_name <- function(df, edition) {
    df$items[df$items$edition %>% detect_index(~ . == edition),]
}

ons_version_by_version <- function(df, version) {
    df$items[df$items$version %>% detect_index(~ . == version),]
}

## END TODO - make these fns more general?

ons_download_by_format <- function(df, format) {
    df$downloads[[format]]
}


## TODO - is there a std fn for this?
log_panic <- function(...) {
    log_error(...)
    quit(status=1)
}

##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##' @title
##' @param df
##' @param id
##' @param edition
##' @param version
##' @return
##' @author neale
ons_dataset_by_id <- function (df, id, edition, version) {
    links <- ons_item_by_id(df,id)$links
    if (missing(edition)) {
        log_info("Edition not specified, defaulting to  latest version")
        link <- links$latest_version$href
    } else {
        metadata <-
            fromJSON(links$editions$href) %>%
            ons_edition_by_name(edition)

        is_latest <- FALSE
        if (missing(version)) {
            log_info("Version of ", edition, " edition not specified, defaulting to latest version")
            link <- metadata$links$latest_version$href
            is_latest <- TRUE
        } else {
            version_metadata = fromJSON(metadata$links$versions$href) %>% ons_version_by_version(version)
            print(version_metadata)
            if (nrow(version_metadata) == 0) {
                log_panic("Version ", version, " of ", edition, " is not available")
            } else {
                log_info("Version ", version, " of ", edition, " edition selected")
            }

            link <- version_metadata$links$self$href

            ## TODO should we work out whether the specified version is the latest here?
            ##      is 'latest' highest version or newest release-date ?
        }
    }

    log_info(sprintf("Retrieving dataset metadata from %s", link))
    dataset <- fromJSON(link)
    dataset$is_latest <- is_latest

    dataset
}


##' Safe Download
##'
##' \code{(safe_download)} downloads a file and tries hard to tidy up in
##' the event of errors. Since these files are typically large we don't
##' want to leave them in temp directories.
##'
##' The destfile should only appear if the download was successful.
##'
##' @param url
##' @param destfile
##' @param fvalidate
safe_download <- function (url, destfile, fvalidate) {
    success = TRUE

    tryCatch({
        tmp <- tempfile()
        curl_download(url=url,
                      destfile=tmp)

        if(!missing(fvalidate) && !fvalidate(tmp)) {
            success = FALSE
            ## report the destfile name to not confuse user, although not strictly true
            log_panic("file ", destfile, " failed validation. Deleting it")
        }

        ## rename to final destination. This is generally an atomic operation, so
        ## we can assume the final file only appears if this succeeds.
        if (success && !file.rename(from=tmp,
                                    to=destfile)) {
            success = FALSE
            log_panic("file ", destfile, " Not created!")
        }
    },
    finally = if (file.exists(tmp)) {file.remove(tmp)})

    success
}

#' Write Metadata
#'
#' \code{(write_metadata)} writes some metadata about where the file came from.
#' TODO - could do this with fs xattr, but maybe that's not well known by users?
#'
#' @param metadata
#' @param destfile
write_metadata <- function (metadata, destfile) {
    json <-toJSON(metadata, pretty=TRUE, flatten=TRUE)
    tryCatch ({
        f <- file(destfile)
        writeLines(c(json), con=f, sep='')
    },
    finally = close(f)
    )
}

#' Download
#'
#' \code{ons_download} retrieves the data described by the given df
#' @param df
ons_download <- function (df, filebase, format="csv") {
    download <-
        df %>%
        ons_download_by_format(format)  ## TODO - error if format not found?

    validate_file <- function(f) {
        expected_size = as.numeric(download$size)

        if (file.size(f) != expected_size) {
            log_panic(sprintf("Inconsistent file size expected %d, got %d",
                              expected_size,
                              file.size(f)))
            FALSE
        } else {
            TRUE
        }
    }

    log_info(sprintf("Downloading data from %s", download$href))

    destfile <- here::here('data','original data',
                           sprintf("%s.v%02d.%s", filebase, as.numeric(df$version), format))

    if (safe_download(url=c(download$href),
                      destfile=destfile,
                      fvalidate=validate_file)) {
        write_metadata(df, sprintf("%s.meta.json", destfile))
        log_info(sprintf("File created at %s ", destfile))
    }

    if (df$is_latest) {
        file.symlink(destfile,
                     here::here('data','original data',
                                sprintf("%s.LATEST.%s", filebase, format)))
    }

    df
}

#' ONS Datasets Setup
#'
ons_datasets_setup <- function() {
    fromJSON("https://api.beta.ons.gov.uk/v1/datasets")
}

ons_datasets_setup() %>%
    ons_dataset_by_id("weekly-deaths-local-authority", edition="time-series") %>%
    ons_download(filebase="weekly-deaths-local-authority",
                 format="csv")
