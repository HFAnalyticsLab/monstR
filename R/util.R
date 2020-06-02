
##' @title Safe Download
##'
##' Downloads a file and tries hard to tidy up in
##' the event of errors. Since these files are typically large we don't
##' want to leave them in temp directories.
##'
##' The destfile should only appear if the download was successful.
##'
##' @param url src for the download
##' @param destfile destination filename
##' @param fvalidate a fn that is passed the filename after download to
##'     validate it in some way. The fn should return TRUE if the file
##'     is valid.
##' @import curl
safe_download <- function(url, destfile, fvalidate) {
    success <- TRUE

    tryCatch({
        tmp <- tempfile()
        curl::curl_download(url = url,
                            destfile = tmp)

        if (!missing(fvalidate) && !fvalidate(tmp)) {
            success <- FALSE
            ## report the destfile name to not confuse user, although not strictly true
            log_panic("file ", destfile, " failed validation. Deleting it")
        }

        ## rename to final destination. This is generally an atomic operation, so
        ## we can assume the final file only appears if this succeeds.
        if (success && !file.rename(from = tmp,
                                    to = destfile)) {
            success <- FALSE
            log_panic("file ", destfile, " Not created!")
        }
    },
    finally = if (file.exists(tmp)) file.remove(tmp))

    success
}

#' @title Write Metadata
#'
#' \code{(write_metadata)} writes some metadata about where the file came from.
#' TODO - could do this with fs xattr, but maybe that's not well known by users?
#'
#' @param metadata a dataframe containing metadata
#' @param destfile filename into which the metadata should be written as JSON
write_metadata <- function(metadata, destfile) {
    json <- jsonlite::toJSON(metadata, pretty = TRUE, flatten = TRUE)
    tryCatch({
        f <- file(destfile)
        writeLines(c(json), con = f, sep = "")
    },
    finally = close(f)
    )
}
