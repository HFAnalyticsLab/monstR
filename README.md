# monstR - making ONS tables readable


#### Project Status: in progress

![R-CMD-check](https://github.com/HFAnalyticsLab/Open_data_pipelines/workflows/R-CMD-check/badge.svg)

## Project Description

This package is a part of our open-source R pipeline to download and clean public data related to health and social care. The aim is to provide analysts, primarily at the Health Foundation, with clean and ready for analysis data. 

## Overview

monstR - making ONS tables readable is a package that queries the [Office for National Statistics (ONS) API](https://developer.ons.gov.uk/office-for-national-statistics-api/reference) to download data. It can be used to retrieve publically available data and meta data from the ONS.

- `ons_available_datasets()` returns information about available datasets
- `ons_available_versions()` returns information about available dataset versions
- `ons_available_editions()` returns information about available dataset editions
- `ons_download()` downloads the specified data


## Installation


If you have cloned a local copy of the repo, you should be able to load it using devtools

<pre>
<!-- use a pre to allow italics, urrgh -->
library(devtools)
setwd("<i>{location of Open_data_pipelines repo}</i>")
devtools::load_all()
</pre>

or to install direct from Github
```
remotes::install_github("HFAnalyticsLab/Open_data_pipelines", build_vignettes = TRUE )
```

## Design Principles

The THF Open Data Pipeline is designed to work well with tidyverse and in particular within pipelines created by the `%>%` pipe operator. With this in mind, most functions take a dataframe (or equivalent, such as a `dplyr::tibble`) in the first argument and return a dataframe which has been augmented in some way.


## Authors
* **Neale Swinnerton** -  [Github](https://github.com/sw1nn)

## License

This project is licensed under the [MIT License](https://github.com/HFAnalyticsLab/Open_data_pipelines/blob/master/LICENSE).
