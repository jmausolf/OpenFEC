####################################
## Load Contrib SOURCE
####################################

#source("indiv_source.R")
source("hca400_functions.R")
#source("indiv_vartab_varplot_functions.R")


########################################
## Infer Partisanship from Clusters
########################################

infer_partisanship <- function(df) {

  cluster_party_key <- df %>% 
    group_by(cluster) %>%
    summarize(mean_pid2_med = mean(median_pid2, na.rm = TRUE),
              mean_ps_med = mean(median_ps, na.rm = TRUE),
              ) %>% 
    mutate(cluster_party = "OTH") %>% 
    mutate(cluster_party = ifelse(    mean_pid2_med == max(mean_pid2_med) &
                                      mean_ps_med == max(mean_ps_med), 
                                      "REP", cluster_party )) %>% 
    mutate(cluster_party = ifelse(    mean_pid2_med == min(mean_pid2_med) &
                                      mean_ps_med == min(mean_ps_med), 
                                      "DEM", cluster_party )) %>% 
    select(cluster, cluster_party)
    
  df_out <- left_join(df, cluster_party_key, by = 'cluster') 
  return(df_out)



}



########################################
## HCA Loop Function
########################################

hca_by_cycle <- function(df, year1, year2, hca_method="agnes_ward", k=3) {

  alg = strsplit(hca_method, '_')[[1]][1]
  method = strsplit(hca_method, '_')[[1]][2]

  hca_df <- prepare_hca_df(df, year1, year2)
  print(hca_df)
  df_org <- hca_df[[1]]
  df <- hca_df[[2]]
  
  hca <- agnes(df, method = method)

  df_post_cluster <- post_cluster_df(df_analysis, df_org, hca, year1, year2)
  
  #print(df_post_cluster)
  
  df_party_clusters <- infer_partisanship(df_post_cluster) 
  
  return(df_party_clusters)

  #Need another function to infer the type of firm of the three clusters
  #dem, rep, amph based on metrics
  #since 1, 2, 3 are meaningless as they change from cycle to cycle or year group



}

cycles <- c(1980, 1982, 1984, 1986, 1988,
            1990, 1992, 1994, 1996, 1998,
            2000, 2002, 2004, 2006, 2008,
            2010, 2012, 2014, 2016, 2018)

#cycles <- c(2002, 2004)

single_election_cycles <- list()
base_cycle_and_next_cycle <- list()
base_cycle_and_last_cycle <- list()

#Cluster For All Single Election Cycles
for (i in seq_along(cycles)) {
  c1 = cycles[[i]]
  c2 = cycles[[i]]
  print(c(c1, c2))
  df_tmp <- hca_by_cycle(df_analysis, c1, c2)
  single_election_cycles[[i]] <- df_tmp
}

#Cluster Base Cycle and Next Cycle 
for (i in seq_along(cycles)) {
  c1 = cycles[[i]]
  c2 = cycles[[i]]+2
  print(c(c1, c2))
  df_tmp <- hca_by_cycle(df_analysis, c1, c2)
  base_cycle_and_next_cycle[[i]] <- df_tmp
}

#Cluster Base Cycle and Last Election Cycle
for (i in seq_along(cycles)) {
  c1 = cycles[[i]]-2
  c2 = cycles[[i]]
  print(c(c1, c2))
  df_tmp <- hca_by_cycle(df_analysis, c1, c2)
  base_cycle_and_last_cycle[[i]] <- df_tmp
}


df_hca_cycles <- bind_rows(
                  single_election_cycles,
                  base_cycle_and_next_cycle,
                  base_cycle_and_last_cycle
                  ) %>%
  distinct() %>%
  mutate(cycle_min = as.character(cycle_min),
         cycle_max = as.character(cycle_max),
         cycle_mean = as.character(cycle_mean))



#TODO Using the HCA Loop Data
#Impose a further classification
#Instead of just what the class is for a given year,
#Prior to Join, Create A Stable Dem, Stable Rep, Stable Amphibious
#DEM/OTHER --> REP (REP Converts) REP/OTHER --> DEM (Dem Converts)
#Waivering --> OTH REP DEM ---> Amphibious



df_refined_clusters <- df_hca_cycles %>% 
  select(cid_master, cycle_mean, cycle_min, cycle_max, cluster_party, median_ps) %>% 
  mutate(cp = as.numeric(factor(cluster_party,
                     levels = c("DEM", "OTH", "REP")))) %>% 
  distinct() %>% 
  arrange(cid_master, cycle_mean) %>%
  mutate(cycle = as.numeric(cycle_mean))

library(nlme)
model1<- lme(cp ~ cycle, data=df_refined_clusters, random= ~cycle | cid_master, method="ML")
mcoefs <- as.data.frame(coef(model1))
mfit <- as.data.frame(fitted(model1))
mpred <- as.data.frame(predict(model1))

df_refined_lme <- bind_cols(df_refined_clusters, mfit) %>% 
  rename(pred = `fitted(model1)`) %>% 
  group_by(cid_master) %>% 
  mutate(mean_pred = mean(pred, na.rm = TRUE)) %>% 
  select(-cycle)


# join post cluster to df_analysis
df_hca_all <- left_join(df_analysis, df_refined_lme, 
                        by = c("cid_master" = "cid_master", 
                               "contributor_cycle" = "cycle_mean"))
mean(df_hca_all$partisan_score, na.rm = TRUE)
table(df_hca_all$pid2)


## join post cluster to df_analysis
df_hca_all_dem <- df_hca_all %>% 
  #filter(cluster_party == "DEM")
  filter(mean_pred <= 1.6)
mean(df_hca_all_dem$partisan_score, na.rm = TRUE)
table(df_hca_all_dem$pid2)

## join post cluster to df_analysis
df_hca_all_rep <- df_hca_all %>% 
  #filter(cluster_party == "REP")
  filter(mean_pred >= 2.4)
mean(df_hca_all_rep$partisan_score, na.rm = TRUE)
table(df_hca_all_rep$pid2)


## join post cluster to df_analysis
df_hca_all_oth <- df_hca_all %>% 
  #filter(cluster_party == "OTH")
  filter(mean_pred >= 1.6 & mean_pred <= 2.4)
mean(df_hca_all_oth$partisan_score, na.rm = TRUE)
table(df_hca_all_oth$pid2)




