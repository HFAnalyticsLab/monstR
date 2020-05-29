library(curl)
library(rvest)  
library(polite)
library(stringr)
library(jsonlite)
library(purrr)
library(logger)

## TODO - make these fns more general?
ons_item_by_id <- function(df, id) {
    df$items[df$items$id %>% detect_index(~ . == id),]
}

ons_edition_by_name <- function(df, edition) {
    df$items[df$items$edition %>% detect_index(~ . == edition),]
}

ons_download_by_format <- function(df, format) {
    df$downloads[[format]]
}

ons_dataset_by_id <- function (df, id, edition, version) {
    links <- ons_item_by_id(df,id)$links
    if (missing(edition)) {
        log_info("Edition not specified, defaulting to  latest version")
        link <- links$latest_version$href
    } else {
        metadata <-
            fromJSON(links$editions$href) %>%
            ons_edition_by_name(edition)

        if (missing(version)) {
            log_info("Version of ", edition, " edition not specified, defaulting to latest version")
            link <- metadata$links$latest_version$href
        } else {
            log_info("Version ", version, " of ", edition, " edition selected")
            link <- sprintf("%s/versions/%d", metadata$links$self$href, version)
        }
    }

    log_info(sprintf("Retrieving dataset metadata from %s", link))
    fromJSON(link)
}


safe_download <- function (url, destfile, fvalidate) {
    success = TRUE

    tryCatch({
        tmp <- tempfile()
        curl_download(url=url,
                      destfile=tmp)

        if(!missing(fvalidate) && !fvalidate(tmp)) {
            success = FALSE
            ## report the destfile name to not confuse user, although not strictly true
            log_error("file ", destfile, " failed validation. Deleting it")
        }

        ## rename to final destination. This is generally an atomic operation, so
        ## we can assume the final file only appears if this succeeds.
        if (success && !file.rename(from=tmp,
                                    to=destfile)) {
            success = FALSE
            log_error("file ", destfile, " Not created!")
        }
    },
    finally = if (file.exists(tmp)) {file.remove(tmp)})

    success
}

write_metadata <- function (metadata, destfile) {
    json <-toJSON(metadata, pretty=TRUE, flatten=TRUE)
    tryCatch ({
        f <- file(destfile)
        writeLines(c(json), con=f, sep='')
    },
    finally = close(f)
    )
}

ons_download <- function (df, filebase, format="csv") {
    metadata <-
        df %>%
        ons_download_by_format(format)  ## TODO - error if format not found?

    validate_file <- function(f) {
        expected_size = as.numeric(metadata$size)

        if (file.size(f) != expected_size) {
            log_error(sprintf("Inconsistent file size expected %d, got %d",
                              expected_size,
                              file.size(f)))
            FALSE
        } else {
            TRUE
        }
    }

    log_info(sprintf("Downloading data from %s", metadata$href))

    destfile <- here::here('data','original data',
                           sprintf("%s.%s", filebase, format))
    if (safe_download(url=c(metadata$href),
                      destfile=destfile,
                      fvalidate=validate_file)) {
        write_metadata(metadata, sprintf("%s.meta.json", destfile))
        log_info(sprintf("File created at %s ", destfile))
    }
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






## # Download daily deaths data to recreate ONS chart
## download.file(
##     "https://www.ons.gov.uk/generator?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/bulletins/deathsregisteredweeklyinenglandandwalesprovisional/weekending24april2020/5db9eecb&format=csv",
##     destfile = here::here('data','original data', "Figure_7_The_number_of_COVID_19_deaths_in_care_homes_continues_to_increase.csv"),
##     mode = "wb")

## deaths_by_local_authority <-
##     fromJSON("https://api.beta.ons.gov.uk/v1/datasets") %>%
##     ons_dataset_by_id("weekly_deaths_local_authority")


## # 2020 - URL scraped from website
## # COVID----
## # Grab links from website
## link <- 'https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/datasets/weeklyprovisionalfiguresondeathsregisteredinenglandandwales'
## bow(link)
## page <- read_html(link)
## links <- page %>% html_nodes(css=".btn--thick") %>% html_attr('href')

## file_names <- fs::path_file(links)

## link_2020 <- links[str_detect(links, '2020.')]

## destfile_ONS <- here::here('data', 'original data', "2020Mortality.xlsx")
## curl_download(paste0('https://www.ons.gov.uk/', link_2020), destfile = destfile_ONS)



## # 2019
## download.file(
##     "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2019/publishedweek522019.xls",
##     destfile = here::here('data','original data', "2019Mortality.xls"),
##     mode = "wb")

## # 2018
## download.file(
##     "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2018/publishedweek522018withupdatedrespiratoryrow.xls",
##     destfile = here::here('data','original data', "2018Mortality.xls"),

##     mode = "wb")

## # 2017
## download.file(
##     "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2017/publishedweek522017.xls",
##     destfile = here::here('data','original data', "2017Mortality.xls"),
##     mode = "wb")

## # 2016
## download.file(
##     "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2016/publishedweek522016.xls",
##     destfile = here::here('data','original data', "2016Mortality.xls"),

##     mode = "wb")

## # 2015
## download.file(
##     "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2015/publishedweek2015.xls",
##     destfile = here::here('data','original data', "2015Mortality.xls"),
##     mode = "wb")

## # 2014
## download.file(
##     "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2014/publishedweek2014.xls",
##     destfile = here::here('data','original data', "2014Mortality.xls"),
##     mode = "wb")

## # 2013
## download.file(
##     "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2013/publishedweek2013.xls",
##     destfile = here::here('data','original data', "2013Mortality.xls"),
##     mode = "wb")

## # 2012
## download.file(
##     "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2012/publishedweek2012.xls",
##     destfile = here::here('data','original data', "2012Mortality.xls"),
##     mode = "wb")

## # 2011
## download.file(
##     "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2011/publishedweek2011.xls",
##     destfile = here::here('data','original data', "2011Mortality.xls"),
##     mode = "wb")

## # 2010
## download.file(
##     "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2010/publishedweek2010.xls",
##     destfile = here::here('data','original data', "2010Mortality.xls"),
##     mode = "wb")
