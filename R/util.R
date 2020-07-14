
##' @title Safe Download
##'
##' Downloads a file and tries hard to tidy up in the event of
##' errors. Since these files are typically large we don't want to
##' leave them in temp directories.
##'
##' The destfile should only appear if the download was successful.
##'
##' @param url src for the download
##' @param destfile destination filename
##' @param fvalidate a fn that is passed the filename after download
##'     to validate it in some way. The fn should return TRUE if the
##'     file is valid.
##' @importFrom curl curl_download
safe_download <- function(url, destfile, fvalidate) {
    success <- TRUE

    tryCatch({
        tmp <- tempfile()
        curl::curl_download(url = url,
                            destfile = tmp)

        if (!missing(fvalidate) && !fvalidate(tmp)) {
            success <- FALSE
            ## report the destfile name to not confuse user, although
            ## not strictly true
            log_panic("file ", destfile, " failed validation. Deleting it")
        }

        ## rename to final destination. This is generally an atomic
        ## operation, so we can assume the final file only appears if
        ## this succeeds.
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
#' \code{(write_metadata)} writes some metadata about where the file
#' came from.  TODO - could do this with fs xattr, but maybe that's
#' not well known by users?
#'
#' @param metadata a dataframe containing metadata
#' @param destfile filename into which the metadata should be written
#'     as JSON
write_metadata <- function(metadata, destfile) {
    json <- jsonlite::toJSON(metadata, pretty = TRUE, flatten = TRUE)
    tryCatch({
        f <- file(destfile)
        writeLines(c(json), con = f, sep = "")
    },
    finally = close(f)
    )
}


##' @title generate a filename for a download
##'
##' @param template \link{whisker} template
##' @param root the root of the directory hierarchy
##' @param data data used to populate the template
##' @param create_directory boolean indicating whether to
##'     (recursively) create the directory hierarchy.
##' @return a filename
##' @import whisker
generate_download_filename <- function(template, root, data, create_directory=TRUE) {

    path <- whisker.render(template,
                           data)

    dir <- dirname(path)

    if (create_directory && !dir.exists(dir)) {
        logger::log_info("Creating directory ", dir)
        dir.create(dir, recursive=TRUE)
    }

    path

}

##' @title write the data as a csv.
##' @param data The actual data
##' @param monstr metadata dataframe created by the pipeline
##' @param create_directory boolean indicating whether to
##'     (recursively) create the directory hierarchy.
##' @return boolean indicating success
##' @author Neale Swinnerton <neale@mastodonc.com
##' @import logger
write_csv <- function(data, monstr, create_directory) {
    success <- TRUE
    monstr$format <- "csv"

    destfile <- generate_download_filename(monstr$clean_filename_template,
                                           monstr$download_root,
                                           monstr,
                                           create_directory)
    logger::log_info(sprintf("Writing %s data to %s", monstr$format,  destfile))

    tryCatch (
        write.csv(data, file=destfile),
        error = function(e) {
            success <- FALSE
        }
    )

    success
}


##' @title write the data as a xlsx.
##' @param data The actual data
##' @param monstr metadata dataframe created by the pipeline
##' @param create_directory boolean indicating whether to
##'     (recursively) create the directory hierarchy.
##' @return boolean indicating success
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @import writexl
##' @import logger
write_xlsx <- function(data, monstr, create_directory) {
    success <- TRUE
    monstr$format <- "xlsx"
    destfile <- generate_download_filename(monstr$clean_filename_template,
                                           monstr$download_root,
                                           monstr,
                                           create_directory)
    logger::log_info(sprintf("Writing %s data to %s", monstr$format,  destfile))
    tryCatch (
        writexl::write_xlsx(x=data, path=destfile),
        error = function(e) {
            logger::log_error("Problem writing xlsx")
            success <- FALSE
        })

    success
}

##' @title write the data as a RDS.
##' @param data The actual data
##' @param monstr metadata dataframe created by the pipeline
##' @param create_directory boolean indicating whether to
##'     (recursively) create the directory hierarchy.
##' @return boolean indicating success
##' @author Neale Swinnerton <neale@mastodonc.com>
##' @import logger
write_rds <- function(data, monstr,create_directory) {
    success <- TRUE
    monstr$format <- "rds"
    destfile <- generate_download_filename(monstr$clean_filename_template,
                                           monstr$download_root,
                                           monstr,
                                           create_directory)
    logger::log_info(sprintf("Writing %s data to %s", monstr$format,  destfile))
    tryCatch (
        saveRDS(object=data, file=destfile),

        error = function(e) {
            logger::log_error("Problem writing rds")
            success <- FALSE
        }
)

    success
}
