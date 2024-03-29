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
  #print(hca_df)
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

cycle_lower_bound = 1980
cycle_upper_bound = 2018

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
  if(cycles[[i]] == cycle_upper_bound){
    c2 = cycles[[i]]
  } else{
    c2 = cycles[[i]]+2
  }
  print(c(c1, c2))
  df_tmp <- hca_by_cycle(df_analysis, c1, c2)
  base_cycle_and_next_cycle[[i]] <- df_tmp
}

#Cluster Base Cycle and Last Election Cycle
for (i in seq_along(cycles)) {
  c2 = cycles[[i]]
  if(cycles[[i]] == cycle_lower_bound){
    c1 = cycles[[i]]
  } else{
    c1 = cycles[[i]]-2
  }
  print(c(c1, c2))
  df_tmp <- hca_by_cycle(df_analysis, c1, c2)
  base_cycle_and_last_cycle[[i]] <- df_tmp
}

#Append HCA Cycle Classes
df_hca_cycles <- bind_rows(
                  single_election_cycles,
                  base_cycle_and_next_cycle,
                  base_cycle_and_last_cycle
                  ) %>%
  distinct() %>%
  mutate(cycle_min = as.character(cycle_min),
         cycle_max = as.character(cycle_max),
         cycle_mean = as.character(cycle_mean))


#Determine Party Switches and Firm Classes from HCA Patterns
source("get_indiv_party_switch.R")



###################################
## Method = Final Max Simple
###################################

method = "final_max_simple"
base = TRUE
oth = TRUE

# join post cluster to df_analysis
df_hca_all <- left_join(df_analysis, df_refined_lme, 
                        by = c("cid_master" = "cid_master", 
                               "contributor_cycle" = "cycle_mean"))
mean(df_hca_all$partisan_score, na.rm = TRUE)
table(df_hca_all$pid2)


## join post cluster to df_analysis
df_hca_all_dem <- df_hca_all %>% 
  filter(final_max == "dem")
mean(df_hca_all_dem$partisan_score, na.rm = TRUE)
table(df_hca_all_dem$pid2)

trans_dems <- df_hca_all_dem %>% select(cid_master, party_pat) %>% distinct()
trans_dems

## join post cluster to df_analysis
df_hca_all_rep <- df_hca_all %>% 
  filter(final_max == "rep")
mean(df_hca_all_rep$partisan_score, na.rm = TRUE)
table(df_hca_all_rep$pid2)

trans_reps <- df_hca_all_rep %>% select(cid_master, party_pat) %>% distinct()
trans_reps


## join post cluster to df_analysis
df_hca_all_oth <- df_hca_all %>% 
  filter(final_max == 'oth')
mean(df_hca_all_oth$partisan_score, na.rm = TRUE)
table(df_hca_all_oth$pid2)

trans_oth <- df_hca_all_oth %>% select(cid_master, party_pat) %>% distinct()
trans_oth

check_total = rbind(trans_dems, trans_reps, trans_oth) %>% distinct()

## Make Graphs
source("indiv_mean_party_hca_loop.R")


###################################
## Method = Converts Only
###################################

method = "converts_only"
base = FALSE
oth = FALSE

# join post cluster to df_analysis
df_hca_all <- left_join(df_analysis, df_refined_lme, 
                        by = c("cid_master" = "cid_master", 
                               "contributor_cycle" = "cycle_mean"))
mean(df_hca_all$partisan_score, na.rm = TRUE)
table(df_hca_all$pid2)


## join post cluster to df_analysis
df_hca_all_dem <- df_hca_all %>% 
  filter(party_class == "converted_amp_dem" |
         party_class == "converted_rep_dem"  )
mean(df_hca_all_dem$partisan_score, na.rm = TRUE)
table(df_hca_all_dem$pid2)

trans_dems <- df_hca_all_dem %>% select(cid_master, party_pat) %>% distinct()
trans_dems

## join post cluster to df_analysis
df_hca_all_rep <- df_hca_all %>% 
  filter(party_class == "converted_amp_rep" |
           party_class == "converted_dem_rep"  )
mean(df_hca_all_rep$partisan_score, na.rm = TRUE)
table(df_hca_all_rep$pid2)

trans_reps <- df_hca_all_rep %>% select(cid_master, party_pat) %>% distinct()
trans_reps


## Make Graphs
source("indiv_mean_party_hca_loop.R")



###################################
## Method = Opp Converts Only
###################################

method = "opp_converts_only"
base = FALSE
oth = FALSE

# join post cluster to df_analysis
df_hca_all <- left_join(df_analysis, df_refined_lme, 
                        by = c("cid_master" = "cid_master", 
                               "contributor_cycle" = "cycle_mean"))
mean(df_hca_all$partisan_score, na.rm = TRUE)
table(df_hca_all$pid2)


## join post cluster to df_analysis
df_hca_all_dem <- df_hca_all %>% 
  filter(party_class == "converted_rep_dem")
mean(df_hca_all_dem$partisan_score, na.rm = TRUE)
table(df_hca_all_dem$pid2)

trans_dems <- df_hca_all_dem %>% select(cid_master, party_pat) %>% distinct()
trans_dems

## join post cluster to df_analysis
df_hca_all_rep <- df_hca_all %>% 
  filter(party_class == "converted_dem_rep")
mean(df_hca_all_rep$partisan_score, na.rm = TRUE)
table(df_hca_all_rep$pid2)

trans_reps <- df_hca_all_rep %>% select(cid_master, party_pat) %>% distinct()
trans_reps

## Make Graphs
source("indiv_mean_party_hca_loop.R")




######################################
## Method = Final Max and LME Filter
######################################

method = "final_max_and_lme"
base = TRUE
oth = TRUE

# join post cluster to df_analysis
df_hca_all <- left_join(df_analysis, df_refined_lme, 
                        by = c("cid_master" = "cid_master", 
                               "contributor_cycle" = "cycle_mean"))
mean(df_hca_all$partisan_score, na.rm = TRUE)
table(df_hca_all$pid2)


## join post cluster to df_analysis
df_hca_all_dem <- df_hca_all %>% 
  filter(final_max == 'dem' & mean_pred <= 1.65)
mean(df_hca_all_dem$partisan_score, na.rm = TRUE)
table(df_hca_all_dem$pid2)

trans_dems <- df_hca_all_dem %>% select(cid_master, party_pat) %>% distinct()
trans_dems

## join post cluster to df_analysis
df_hca_all_rep <- df_hca_all %>% 
  filter(final_max == 'rep' & mean_pred >= 2.35)
mean(df_hca_all_rep$partisan_score, na.rm = TRUE)
table(df_hca_all_rep$pid2)

trans_reps <- df_hca_all_rep %>% select(cid_master, party_pat) %>% distinct()
trans_reps


## join post cluster to df_analysis
df_hca_all_oth <- df_hca_all %>% 
  filter((final_max == 'oth') | (final_max != 'oth' & mean_pred < 2.35 & mean_pred > 1.65))
mean(df_hca_all_oth$partisan_score, na.rm = TRUE)
table(df_hca_all_oth$pid2)

trans_oth <- df_hca_all_oth %>% select(cid_master, party_pat) %>% distinct()
trans_oth

check_total = rbind(trans_dems, trans_reps, trans_oth) %>% distinct()

## Make Graphs
source("indiv_mean_party_hca_loop.R")

