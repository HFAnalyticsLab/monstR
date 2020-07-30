# monstR - making ONS tables readable  <a><img src='man/figures/monstR_2.png' align="right" height="139" /></a>
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-7-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

![R-CMD-check](https://github.com/HFAnalyticsLab/Open_data_pipelines/workflows/R-CMD-check/badge.svg)

#### Project Status: in progress
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

## Examples

This is an example of how to download weekly mortality data by region. Note that this will create folders and download data. 

```
monstr_pipeline_defaults() %>%  # Uses the monstr 'standards' for location and format
  ons_datasets_setup() %>% 
	ons_dataset_by_id("weekly-deaths-region") %>%
	ons_download(format="csv") %>%
	monstr_read_file() %>%  
	monstr_clean() %>%
	monstr_write_clean(format="all")

```

## Resources

### Online documentation

You can find the help pages at <https://hfanalyticslab.github.io/monstR//>.

## Questions and bug reports

This is a package under active development and we would love for you to contribute or flag any issues you might find. 

You can ask questions or flag a bug by [filing an issue](https://github.com/HFAnalyticsLab/monstR/issues). We are more likely to be able to help you if we can reproduce your issue. The `reprex` package is a good way of producing a minimal reproducible package and [So you've been asked to make a reprex](https://www.jessemaegan.com/post/so-you-ve-been-asked-to-make-a-reprex/) will help you get started. 

### Contributing to the package development

We aim to make the documentation as comprehensive as possible. Please contribute examples or suggest improvements to the
documentation.

If you have written a function that you think should be added to the package, or improved an existing function, please submit a pull request that includes:

  - the new/amended function(s) with code and roxygen tags (with examples)
  - a new section in the appropriate vignette that describes how to use
    the new function
  - corresponding tests in directory `tests/testthat`.

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
    <td align="center"><a href="https://www.strategyunitwm.nhs.uk/"><img src="https://avatars1.githubusercontent.com/u/12023696?v=4" width="100px;" alt=""/><br /><sub><b>Tom Jemmett</b></sub></a><br /><a href="https://github.com/HFAnalyticsLab/monstR/issues?q=author%3Atomjemmett" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/JohnHC86"><img src="https://avatars1.githubusercontent.com/u/12610020?v=4" width="100px;" alt=""/><br /><sub><b>JohnHC86</b></sub></a><br /><a href="https://github.com/HFAnalyticsLab/monstR/issues?q=author%3AJohnHC86" title="Bug reports">🐛</a></td>
    <td align="center"><a href="http://sw1nn.com"><img src="https://avatars1.githubusercontent.com/u/373335?v=4" width="100px;" alt=""/><br /><sub><b>Neale Swinnerton</b></sub></a><br /><a href="https://github.com/HFAnalyticsLab/monstR/commits?author=sw1nn" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/fiona-grimm"><img src="https://avatars1.githubusercontent.com/u/31844347?v=4" width="100px;" alt=""/><br /><sub><b>fiona-grimm</b></sub></a><br /><a href="#ideas-fiona-grimm" title="Ideas, Planning, & Feedback">🤔</a> <a href="#design-fiona-grimm" title="Design">🎨</a></td>
    <td align="center"><a href="https://github.com/SimonCRUK"><img src="https://avatars2.githubusercontent.com/u/58686505?v=4" width="100px;" alt=""/><br /><sub><b>SimonCRUK</b></sub></a><br /><a href="https://github.com/HFAnalyticsLab/monstR/issues?q=author%3ASimonCRUK" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/Lextuga007"><img src="https://avatars0.githubusercontent.com/u/39963221?v=4" width="100px;" alt=""/><br /><sub><b>Zoe Turner</b></sub></a><br /><a href="https://github.com/HFAnalyticsLab/monstR/issues?q=author%3ALextuga007" title="Bug reports">🐛</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
