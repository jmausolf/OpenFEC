library(stringr)
library(tidyverse)


#############################
## Create Crosswalk
#############################

match_key = read_csv("msci_data/match_key_edit.csv")

companies_hca <- df_analysis %>% 
  ungroup() %>% 
  select(cid_master) %>% 
  distinct()

crosswalk <- left_join(companies_hca, match_key, by=c("cid_master" = "company")) %>% 
  filter(!is.na(CompanyName)) %>% 
  ##Remove Odd Company Names
  filter(CompanyName != 'ADELAIDE BRIGHTON LTD.')


#################################
## Join Crosswalk with MSCI Data
#################################

msci_data <- read_csv("msci_data/MSCI_ALL_1991_2016.csv")

msci_key <- msci_data %>%
  select(CompanyName, ticker, CUSIP, YEAR) %>% 
  distinct() %>% 
  arrange(CompanyName)

## Get Different Match Types and Clean
cusip_match <- left_join(crosswalk, msci_key) %>% 
  filter(!is.na(CUSIP),
         CUSIP != 0) %>% 
  select(cid_master, CUSIP) %>% 
  distinct() %>% 
  left_join(msci_key) %>% 
  arrange(cid_master, YEAR) %>% 
  select(cid_master, CompanyName, CUSIP, ticker, YEAR)

ticker_match <- left_join(crosswalk, msci_key) %>% 
  filter(!is.na(ticker)) %>% 
  select(cid_master, ticker) %>% 
  distinct() %>% 
  left_join(msci_key) %>% 
  arrange(cid_master, YEAR) %>% 
  mutate(cid_master_lower = str_to_lower(cid_master),
         CompanyName_lower = str_to_lower(CompanyName)) %>% 
  mutate(authorised = str_detect(CompanyName_lower, cid_master_lower)) %>% 
  filter(authorised == TRUE) %>% 
  select(-CompanyName_lower, -cid_master_lower, -authorised) %>% 
  select(cid_master, CompanyName, CUSIP, ticker, YEAR)

name_match <- left_join(crosswalk, msci_key) %>% 
  select(cid_master, ticker, CompanyName) %>% 
  distinct() %>% 
  select(-ticker) %>% 
  left_join(msci_key) %>% 
  arrange(cid_master, YEAR) %>% 
  mutate(cid_master_lower = str_to_lower(cid_master),
         CompanyName_lower = str_to_lower(CompanyName)) %>% 
  mutate(authorised = str_detect(CompanyName_lower, cid_master_lower)) %>% 
  filter(authorised == FALSE) %>% 
  select(-CompanyName_lower, -cid_master_lower, -authorised) %>% 
  select(cid_master, CompanyName, CUSIP, ticker, YEAR)

## Join Match Types and Keep Distinct
msci_match_key <- bind_rows(cusip_match, ticker_match, name_match) %>% 
  distinct() %>% 
  arrange(cid_master, YEAR) 



#################################
## Join MSCI Match Key with FEC 
#################################

#TODO Run TS_HSA on Successive Time Windows in A Loop
#i.e. run 1980, (1980, 1982),...(1980...1998)...(1980...2000)... 

#Make Base
msci_base <- left_join(msci_match_key, msci_data)

#Drop All NA Cols or Some NA Cols
msci_base <- Filter(function(x)!all(is.na(x)), msci_base)
# msci_base <- msci_base[ , colSums(is.na(msci_base)) == 0]
# names(msci_base)

#Join With Post Cluster Data

msci_cluster_m0 <- left_join(df_post_cluster_m0, msci_base,
                             by = c("cid_master" = "cid_master", 
                                    "cycle" = "YEAR"))

#TODO SELECT ONLY NUMERIC DATA
#dat <- sapply( dat, as.numeric )

cormat <- round(cor(msci_cluster_m0),2)
head(cormat)
