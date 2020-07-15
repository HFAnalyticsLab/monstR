# monstR - making ONS tables readable <a href='https://github.com/HFAnalyticsLab/monstR'><img src='man/figures/monstR_2.png' align="right" height="139" /></a>
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
remotes::install_github("HFAnalyticsLab/monstR", build_vignettes = TRUE )
```

## Design Principles

The MONSTR Open Data Pipeline is designed to work well with tidyverse and in particular within pipelines created by the `%>%` pipe operator. With this in mind, most functions take a data structure in the first argument and return a data structure which has been augmented in some way. Typically this is metadata about the actual data, although once the data has been cleaned it can be accessed using `monstr_data(metadata)` to get at a tidyverse tibble of the data.


## Authors
* **Neale Swinnerton** -  [Github](https://github.com/sw1nn)

## License

This project is licensed under the [MIT License](https://github.com/HFAnalyticsLab/Open_data_pipelines/blob/master/LICENSE).
