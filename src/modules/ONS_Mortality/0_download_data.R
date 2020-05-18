library(curl)
library(rvest)  
library(polite)

# Download daily deaths data to recreate ONS chart
download.file(
  "https://www.ons.gov.uk/generator?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/bulletins/deathsregisteredweeklyinenglandandwalesprovisional/weekending24april2020/5db9eecb&format=csv",
  destfile = here::here('data','original data', "Figure_7_The_number_of_COVID_19_deaths_in_care_homes_continues_to_increase.csv"),
  mode = "wb")



# 2020 - URL scraped from website
# COVID----
# Grab links from website
link <- 'https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/datasets/weeklyprovisionalfiguresondeathsregisteredinenglandandwales'
bow(link)
page <- read_html(link)
links <- page %>% html_nodes(css=".btn--thick") %>% html_attr('href')

file_names <- fs::path_file(links)

link_2020 <- links[str_detect(links, '2020.')]

destfile_ONS <- here::here('data', 'original data', "2020Mortality.xlsx")
curl_download(paste0('https://www.ons.gov.uk/', link_2020), destfile = destfile_ONS)



# 2019
download.file(
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2019/publishedweek522019.xls",
  destfile = here::here('data','original data', "2019Mortality.xls"),
  mode = "wb")

# 2018
download.file(
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2018/publishedweek522018withupdatedrespiratoryrow.xls",
  destfile = here::here('data','original data', "2018Mortality.xls"),

  mode = "wb")

# 2017
download.file(
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2017/publishedweek522017.xls",
  destfile = here::here('data','original data', "2017Mortality.xls"),
  mode = "wb")

# 2016
download.file(
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2016/publishedweek522016.xls",
  destfile = here::here('data','original data', "2016Mortality.xls"),

  mode = "wb")

# 2015
download.file(
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2015/publishedweek2015.xls",
  destfile = here::here('data','original data', "2015Mortality.xls"),
  mode = "wb")

# 2014
download.file(
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2014/publishedweek2014.xls",
  destfile = here::here('data','original data', "2014Mortality.xls"),
  mode = "wb")

# 2013
download.file(
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2013/publishedweek2013.xls",
  destfile = here::here('data','original data', "2013Mortality.xls"),
  mode = "wb")

# 2012
download.file(
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2012/publishedweek2012.xls",
  destfile = here::here('data','original data', "2012Mortality.xls"),
  mode = "wb")

# 2011
download.file(
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2011/publishedweek2011.xls",
  destfile = here::here('data','original data', "2011Mortality.xls"),
  mode = "wb")

# 2010
download.file(
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fbirthsdeathsandmarriages%2fdeaths%2fdatasets%2fweeklyprovisionalfiguresondeathsregisteredinenglandandwales%2f2010/publishedweek2010.xls",
  destfile = here::here('data','original data', "2010Mortality.xls"),
  mode = "wb")
