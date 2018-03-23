#python code
#df = pd.DataFrame.from_dict(company_name_ids, orient='index').transpose()
#df.to_csv("company_name_ids.csv")

library(tidyverse)

df = read_csv("company_name_ids.csv")


df_clean <- df %>%
  select(-X1) %>% 
  gather(key = "cid", value = "contributor_employer_clean") %>% 
  filter(!is.na(contributor_employer_clean)) %>% 
  mutate("contributor_occupation_clean" = contributor_employer_clean)

write_csv(df_clean, "company_name_ids_clean.csv")
