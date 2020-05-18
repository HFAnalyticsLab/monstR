library(tidyverse) # CRAN v1.3.0
library(readxl)
library(janitor)

# Daily place of death
daily_place_of_death <- read_csv(here::here('data','original data', 
                                      "Figure_7__The_number_of_COVID-19_deaths_in_care_homes_continues_to_increase.csv"),
                           skip=6)

write_csv(daily_place_of_death, here::here('data', 'daily_place_of_death.csv'))
# reshape data so it is long
df_long <- pivot_longer(daily_place_of_death, -Date, names_to = 'location', 
                        values_to='deaths') %>% 
  mutate(date=paste0(Date, '-2020'), date=lubridate::dmy(date),
         location=fct_recode(location, 'Other*'='Other'))

saveRDS(df_long, here::here('data', 'EW_daily_deaths.rds'))


# Weekly place of death
place_of_death <- read_excel(path=here::here('data', 'original data', '2020Mortality.xlsx'), sheet='Covid-19 - Place of occurrence ')  

ONS <- place_of_death %>%
  clean_names() %>% 
  filter(row_number()<14, row_number()>=3) %>% 
  remove_empty(c("rows","cols")) %>% 
  t() %>% 
  as.data.frame() %>% 
  row_to_names(row_number=1) %>% 
  clean_names() %>% 
  rename(country=na, type_of_death=na_2) %>% 
  fill(week_number, week_ended, country) %>% 
  pivot_longer(-c(week_number, week_ended, country, type_of_death)) %>% 
  pivot_wider(-type_of_death, names_from = type_of_death, 
              values_from = value) %>% 
  clean_names() %>% 
  mutate_all(as.character) %>% 
  mutate_at(vars(week_number, week_ended, total_deaths, covid_19_deaths), as.numeric) %>% 
  rename(location=name) %>% 
  mutate(covid_p=covid_19_deaths/total_deaths) %>% 
  mutate(week_ended=as.Date(week_ended, origin = "1899-12-30"), 
         location_4groups=fct_collapse(location,
                                       "Home" = "home",
                                       "Hospital (acute or community, not psychiatric)" = "hospital_acute_or_community_not_psychiatric",
                                       "Other*" = c("hospice","elsewhere", "other_communal_establishment"),
                                       "Care home" = "care_home"),
         
         location=fct_recode(location,
                             "Home" = "home",
                             "Hospital (acute or community, not psychiatric)" = "hospital_acute_or_community_not_psychiatric",
                             "Hospice" = "hospice",
                             "Care home" = "care_home",
                             "Other communal establishment" = "other_communal_establishment",
                             "Elsewhere" = "elsewhere"), 
)


EW <- ONS %>% 
  filter(country=='England and Wales') %>% 
  mutate(firstweek=ifelse(week_number==11, total_deaths, NA)) %>% 
  group_by(location) %>% 
  fill(firstweek) %>% 
  ungroup() %>% 
  mutate(proportion_0_base=total_deaths/firstweek*100-100) %>% 
  group_by(location_4groups) %>% 
  mutate(firstweek_4groups=ifelse(week_number==11, total_deaths, NA)) %>% 
  group_by(location_4groups) %>% 
  fill(firstweek_4groups) %>% 
  ungroup() %>% 
  mutate(proportion_0_base_4groups=total_deaths/firstweek_4groups*100-100) 


saveRDS(EW, here::here('data', 'EW_weekly_deaths.rds'))

# Save wide data
EW_wide <- EW %>% 
  select( week_ended, location, proportion_0_base) %>% 
  pivot_wider(id_cols = location, names_from = week_ended, values_from = proportion_0_base)
write_csv(EW_wide, here::here('data', 'England_Wales_place_of_death.csv') )

# Save wide data 4 groups
EW_wide_4groups <- EW %>% 
  distinct(week_ended, location_4groups, .keep_all = TRUE) %>% 
  select( week_ended, location_4groups, proportion_0_base_4groups) %>% 
  pivot_wider(id_cols = location_4groups, names_from = week_ended, values_from = proportion_0_base_4groups)
write_csv(EW_wide_4groups, here::here('data', 'England_Wales_place_of_death_4groups.csv') )


