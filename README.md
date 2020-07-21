# monstR - making ONS tables readable 
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->
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
setwd("<i>{location of monstR repo}</i>")
devtools::load_all()
</pre>

or to install direct from Github
```
remotes::install_github("HFAnalyticsLab/monstR", build_vignettes = TRUE )
```

## Design Principles

The monstrR Open Data Pipeline is designed to work well with tidyverse and in particular within pipelines created by the `%>%` pipe operator. With this in mind, most functions take a data structure in the first argument and return a data structure which has been augmented in some way. Typically this is metadata about the actual data, although once the data has been cleaned it can be accessed using `monstr_data(metadata)` to get at a tidyverse tibble of the data.


## Authors
* **Neale Swinnerton** -  [Github](https://github.com/sw1nn)
* **Emma Vestesson** -  [Github](https://github.com/emmavestesson) [Twitter](https://twitter.com/Gummifot)

## License

This project is licensed under the [MIT License](https://github.com/HFAnalyticsLab/monstR/blob/master/LICENSE).

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://emmavestesson.netlify.com/"><img src="https://avatars2.githubusercontent.com/u/31949401?v=4" width="100px;" alt=""/><br /><sub><b>Emma Vestesson</b></sub></a><br /><a href="#ideas-emmavestesson" title="Ideas, Planning, & Feedback">🤔</a> <a href="#content-emmavestesson" title="Content">🖋</a> <a href="https://github.com/HFAnalyticsLab/monstR/commits?author=emmavestesson" title="Documentation">📖</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!