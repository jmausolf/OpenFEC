####################################
## Load SOURCE
####################################

#source("indiv_source.R")
#source("indiv_vartab_varplot_functions.R")



####################################
## Make Descriptive Stats Tables
####################################


# define the markup language we are working in.
options(qwraps2_markup = "latex") 

##Number Filter 
nf = 10
df_analysis <- df_filtered %>%
  filter(n_indiv_raw >= nf) %>%
  filter(n_indiv_pid >= nf) %>% 
  filter(n_indiv_ps >= nf) %>% 
  filter(n_contrib >= nf) 



#Define Primary Summary Stats DF
df_stats <- df_analysis %>% 
  select(contributor_cycle,
         cid_master,
         pid2,
         partisan_score,
         #occ3,
         sub_id_count,
         ) %>% 
  mutate(contributor_cycle = as.numeric(contributor_cycle),
         #cid_master = as.numeric((as.factor(cid_master))),
         #occ3 = as.factor(occ3),
         sub_id_count = as.numeric(sub_id_count),
        ) %>% 
  droplevels() %>%
  rename("Major Party ID" = pid2,
         "Partisan Score" = partisan_score,
         #"Organizational Hierarchies" = occ3
         ) %>% 
  mutate(p = as.numeric(contributor_cycle),
         p = if_else(p <= 1988, "1980-1988",
                     if_else(p >= 1990 & p <= 1998, "1990-1998",
                     if_else(p >= 2000 & p <= 2008, "2000-2008",
                     if_else(p >= 2010 & p <= 2018, "2010-2018",
                             "unknown"))))
         
         ) %>% 
  rename("Period" = p)


#Method for Total Contrib
total_contrib <-
  list(
    "Individual Contributions" =
      list("total" = ~ sum(.data$sub_id_count),
           "minimum" = ~ min(.data$sub_id_count),
           "median (IQR)" = ~ median_iqr(.data$sub_id_count),
           "mean (sd)" = ~ qwraps2::mean_sd(.data$sub_id_count),
           "maximum" = ~ max(.data$sub_id_count))
  )


#Method for Total Firms
total_firms <- 
  list(
    "Firms" =
      list("total" = ~ n_distinct(.data$cid_master))
  )


################################
## Main Table / All Periods
################################

#Define DF for Main Stats
df_main <-  df_stats %>% 
  select(-sub_id_count, -contributor_cycle, -cid_master, -Period)

#Make Main Stats Table 
main_all <- df_main %>% 
  summary_table(.)

#Make Table for Total Contrib
contrib_all <- df_stats %>% 
  summary_table(total_contrib)

#Make Table for Total Firms
firms_all <- df_stats %>% 
  summary_table(total_firms)

#Combined Table for All Data
tab_all <- rbind(main_all, contrib_all, firms_all)
tab_all


################################
## Table 80s
################################

#Define DF for Main Stats
df_main <-  df_stats %>% 
  select(-sub_id_count, -contributor_cycle, -cid_master)

#Make Main Stats Table 
main_80s <- df_main %>% 
  filter(Period == "1980-1988") %>% 
  select(-Period) %>% 
  summary_table(.)

#Make Table for Total Contrib
contrib_80s <- df_stats %>% 
  filter(Period == "1980-1988") %>% 
  summary_table(total_contrib)

#Make Table for Total Firms
firms_80s <- df_stats %>% 
  filter(Period == "1980-1988") %>% 
  summary_table(total_firms)

#Combined Table for All Data
tab_80s <- rbind(main_80s, contrib_80s, firms_80s)
tab_80s


################################
## Table 90s
################################

#Define DF for Main Stats
df_main <-  df_stats %>% 
  select(-sub_id_count, -contributor_cycle, -cid_master)

#Make Main Stats Table 
main_90s <- df_main %>% 
  filter(Period == "1990-1998") %>% 
  select(-Period) %>% 
summary_table(.)

#Make Table for Total Contrib
contrib_90s <- df_stats %>% 
  filter(Period == "1990-1998") %>% 
  summary_table(total_contrib)

#Make Table for Total Firms
firms_90s <- df_stats %>% 
  filter(Period == "1990-1998") %>% 
  summary_table(total_firms)

#Combined Table for All Data
tab_90s <- rbind(main_90s, contrib_90s, firms_90s)
tab_90s


################################
## Table 00s
################################

#Define DF for Main Stats
df_main <-  df_stats %>% 
  select(-sub_id_count, -contributor_cycle, -cid_master)

#Make Main Stats Table 
main_00s <- df_main %>% 
  filter(Period == "2000-2008") %>% 
  select(-Period) %>% 
  summary_table(.)

#Make Table for Total Contrib
contrib_00s <- df_stats %>% 
  filter(Period == "2000-2008") %>% 
  summary_table(total_contrib)

#Make Table for Total Firms
firms_00s <- df_stats %>% 
  filter(Period == "2000-2008") %>% 
  summary_table(total_firms)

#Combined Table for All Data
tab_00s <- rbind(main_00s, contrib_00s, firms_00s)
tab_00s


################################
## Table 10s
################################

#Define DF for Main Stats
df_main <-  df_stats %>% 
  select(-sub_id_count, -contributor_cycle, -cid_master)

#Make Main Stats Table 
main_10s <- df_main %>% 
  filter(Period == "2010-2018") %>% 
  select(-Period) %>% 
  summary_table(.)

#Make Table for Total Contrib
contrib_10s <- df_stats %>% 
  filter(Period == "2010-2018") %>% 
  summary_table(total_contrib)

#Make Table for Total Firms
firms_10s <- df_stats %>% 
  filter(Period == "2010-2018") %>% 
  summary_table(total_firms)

#Combined Table for All Data
tab_10s <- rbind(main_10s, contrib_10s, firms_10s)
tab_10s



final_table <- cbind(tab_all, tab_80s, tab_90s, tab_00s, tab_10s)
final_table
