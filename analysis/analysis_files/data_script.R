

## Select Base Features ALL
base_features0_all <- function(input_df, cycle_min = 1980, cycle_max = 2020){
  
  df_filtered <- input_df %>% 
    filter(cycle >= cycle_min & cycle <= cycle_max) %>%  
    filter(!is.na(pid2),
           !is.na(partisan_score),
           !is.na(occ3),
           !is.na(occlevels)) %>% 
    #Group by Company (Collapse Across Cycles)
    group_by(cycle, cid_master) %>% 
    summarize(mean_pid2 = mean(as.numeric(pid2), na.rm = TRUE),
              median_pid2 = median(as.numeric(pid2), na.rm = TRUE),
              mean_ps = mean(partisan_score, na.rm = TRUE),
              median_ps = median(partisan_score, na.rm = TRUE),
              mean_ps_mode = mean(as.numeric(partisan_score_mode), na.rm = TRUE), 
              mean_ps_min = mean(as.numeric(partisan_score_min), na.rm = TRUE),
              mean_ps_max = mean(as.numeric(partisan_score_max), na.rm = TRUE)
    )
  
  return(df_filtered)
  
}

df_base0_all <- base_features0_all(df_analysis, y1, y2)



## Get Polar Prep but for ALL only
df_polarization_prep_1_all <- df_polarization %>% 
  #mutate(occ3 = as.character(occ)) %>% 
  filter(occ == "ALL") %>% 
  filter(!is.na(occ))



## Join Features
df_m0_features_all <- left_join(df_base0_all, df_polarization_prep_1_all)


## Join Model Results
df_m0_results <- left_join(df_m0_features_all, df_clust_simple_m0)


## Get Ranking Feature
df_hca_all_m0 <- df_post_cluster_m0

df_hca_filter <- df_hca_all_m0 %>% 
  filter(cycle >= 2008) %>% 
  group_by(cid_master) %>% 
  mutate(pid2 = as.numeric(pid2)) %>% 
  select(cid_master, pid2, partisan_score, polarization_raw_pid, polarization_raw_ps) %>% 
  summarise_all(list(~mean(.)), na.rm = TRUE) %>% 
  mutate_if(is.numeric, list(~percent_rank(.), ~sum(.))) %>%
  select(cid_master, ends_with("_rank"))



df_hca_all_m0_ranks <- left_join(df_hca_all_m0, df_hca_filter, by = "cid_master") %>% 
  select(cid_master, ends_with("_rank")) %>% 
  distinct()


## Get Model Results and Ranks for Error Filter
df_m0_features_rank <- left_join(df_m0_results, df_hca_all_m0_ranks)


df_mfr_dem <- df_m0_features_rank %>% 
  filter(cluster_party == "DEM") %>% 
  filter(pid2_percent_rank <= 0.26 | partisan_score_percent_rank <= 0.26) 


##QC Filter for Errors
df_mfr_dem <- df_m0_features_rank %>% 
  filter(cluster_party == "DEM") %>% 
  filter(pid2_percent_rank <= 0.26 | partisan_score_percent_rank <= 0.26) 


df_mfr_rep <- df_m0_features_rank %>% filter(cluster_party == "REP") %>% 
  filter(pid2_percent_rank >= 0.74 | partisan_score_percent_rank >= 0.74) 


df_mfr_oth <- df_m0_features_rank %>% filter(cluster_party == "OTH") 

#Get DF with Features by Year
df_m0_features_qc <- rbind(df_mfr_dem, df_mfr_rep, df_mfr_oth)


df_m0_features_qc_out <- df_m0_features_qc %>% 
  select(cycle, cid_master, cluster_party, everything()) %>% 
  select(-occ) %>% 
  arrange(cid_master, cycle)



write_csv(df_m0_features_qc_out, "company_party_polarization.csv")


#Get DF with Features, Firm Level
df_m0_features_qc_firms <- df_m0_features_qc %>% 
  ungroup() %>% 
  select(cid_master, cluster_party) %>% 
  distinct()

##Test to Confirm Same Companies/Clusters Post QC as Analysis
df_test <- rbind(df_hca_all_dem, df_hca_all_rep, df_hca_all_oth) %>% 
  ungroup() %>% 
  select(cid_master, cluster_party) %>% 
  distinct()

df_test2 <- full_join(df_m0_features_qc_firms, df_test)


