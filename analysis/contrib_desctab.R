####################################
## Load Contrib SOURCE
####################################

source("contrib_source.R")



####################################
## Make Table Describing Tables
####################################

fec_tabs <-  read_csv("fec_tables_desc_05302018.csv") %>% 
  select(-`FEC Longform Name`) 

save_stargazer("output/tables/table_descriptive_stats.tex",
               as.data.frame(fec_tabs), header=FALSE, type='latex',
               font.size = "scriptsize",
               digits = 2,
               title = "Descriptive Overview of FEC Data Tables", 
               summary = FALSE,
               rownames = FALSE)


names_ex <-  read_csv("cleaned_names_example.csv") %>% 
  select(-`Name Example Cleaned`)

save_stargazer("output/tables/name_examples.tex",
               as.data.frame(names_ex), header=FALSE, type='latex',
               font.size = "footnotesize",
               title = "Select Example of Possible Name Permutations for John Allen Smith", 
               summary = FALSE,
               rownames = FALSE)



names_ex_cleaned <-  read_csv("cleaned_names_example.csv")

save_stargazer("output/tables/name_examples_cleaned.tex",
               as.data.frame(names_ex_cleaned), header=FALSE, type='latex',
               font.size = "footnotesize",
               title = "Two Discrete Normalized Names for John Allen Smith", 
               summary = FALSE,
               rownames = FALSE)





####################################
## Make Descriptive Stats Tables
####################################


#Summary Stats for Variables in Models
df_stats <- dfocc %>% 
  select(cycle, 
         contributor_name,
         cid,
         cid_master,
         contributor_transaction_amt,
         party_id,
         pid2,
         partisan_score,
         #pid3, 
         #pid5, 
         occlevels, 
         contributor_occupation_clean) %>% 
  mutate(occ3 = fct_collapse(occlevels,
                             "MANAGEMENT" = c("MANAGER", "DIRECTOR"),
                             "OTHERS" = c("ENGINEER", "Other"))) %>% 
  mutate(contributor_name = as.numeric(as.factor(contributor_name)),
         party_id = as.numeric(as.factor(party_id)),
         pid2 = as.numeric(pid2),
         #pid3 = as.numeric(pid3),
         #pid5 = as.numeric(pid5),
         cid = as.numeric(as.factor(cid)),
         cid_master = as.numeric(as.factor(cid_master)),
         occ3 = as.numeric(occ3),
         contributor_occupation = as.numeric(as.factor(contributor_occupation_clean))) %>% 
  rename("Contributor Name" = contributor_name,
         "Contribution Receipt Amount" = contributor_transaction_amt,
         "Presidential Election Cycle" = cycle,
         "Party Identification" = party_id,
         "Major Party ID" = pid2,
         "Partisan Score" = partisan_score,
         "Company ID" = cid,
         "Company Master ID" = cid_master,
         "Contributor Occupation" = contributor_occupation_clean,
         "Organizational Hierarchies" = occ3)


save_stargazer("output/tables/contrib_descriptive_stats.tex",
               as.data.frame(df_stats), header=FALSE, type='latex',
               median = TRUE,
               font.size = "scriptsize",
               digits = 2,
               title = "Descriptive Statistics from the Federal Election Commission (FEC)" )

#stargazer(as.data.frame(df_stats), type = "text", median = TRUE)


