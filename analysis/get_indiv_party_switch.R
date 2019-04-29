library(DataCombine)
source("hca400_functions.R")
library(reshape2)
library(data.table)

test <- df_hca_cycles %>% 
  select(cid_master, cycle_mean, cycle_min, cycle_max, cluster_party, median_ps) %>% 
  mutate(cp = as.numeric(factor(cluster_party,
                     levels = c("DEM", "OTH", "REP")))) %>% 
  #filter(cycle_mean == cycle_max) %>% 
  distinct() %>% 
  arrange(cid_master, cycle_mean) 


cluster_counts <- test %>% 
  group_by(cid_master, cluster_party) %>% 
  summarise(cluster_count = n())

total_count <- test %>% 
  group_by(cid_master) %>% 
  summarise(total_count = n())


cum_counts_dem <- test %>% 
  filter(cluster_party == "DEM") %>% 
  group_by(cid_master, cluster_party, cycle_mean) %>% 
  summarise(cluster_count = n()) %>% 
  mutate(cum_count_dem = cumsum(cluster_count)) %>% 
  ungroup() %>% 
  select(-cluster_party, -cluster_count)

cum_counts_rep <- test %>% 
  filter(cluster_party == "REP") %>% 
  group_by(cid_master, cluster_party, cycle_mean) %>% 
  summarise(cluster_count = n()) %>% 
  mutate(cum_count_rep = cumsum(cluster_count)) %>% 
  ungroup() %>% 
  select(-cluster_party, -cluster_count)


cum_counts_oth <- test %>% 
  filter(cluster_party == "OTH") %>% 
  group_by(cid_master, cluster_party, cycle_mean) %>% 
  summarise(cluster_count = n()) %>% 
  mutate(cum_count_oth = cumsum(cluster_count)) %>% 
  ungroup() %>% 
  select(-cluster_party, -cluster_count)


cum_count_clusters <- left_join(test, cum_counts_dem) %>% 
  left_join(cum_counts_rep) %>% 
  left_join(cum_counts_oth) %>% 
  fill(cum_count_dem) %>% 
  fill(cum_count_rep) %>%  
  fill(cum_count_oth) %>% 
  mutate(cum_count_dem = replace_na(cum_count_dem, 0),
         cum_count_rep = replace_na(cum_count_rep, 0),
         cum_count_oth = replace_na(cum_count_oth, 0)) 


  
  
get_party_max <- cum_count_clusters %>% 
  select(cid_master, cum_count_dem, cum_count_rep, cum_count_oth) 
party_max <- as.data.frame(colnames(get_party_max)[apply(get_party_max,1,which.max)]) %>% 
  rename(maxcol = `colnames(get_party_max)[apply(get_party_max, 1, which.max)]`)


#Establish Count Cluster Base
count_clusters_base <- bind_cols(cum_count_clusters, party_max) %>% 
  mutate(first_max = first(maxcol)) %>% 
  mutate(first_max = str_replace(first_max, "cum_count_", "")) %>% 
  mutate(maxcol = str_replace(maxcol, "cum_count_", "")) %>% 
  mutate(cycle_mean = as.numeric(cycle_mean)) %>% 
  mutate(max_col = as.numeric(as.factor(maxcol)))

#Generate Change Score To Record a Change 
#E.G. Back to Original Maxcol or Other Situation
count_clusters_base <- change(data = count_clusters_base, Var = 'max_col', 
                              TimeVar = 'cycle_mean', GroupVar = 'cid_master', 
                              NewVar = 'switch', slideBy = -1, type = "absolute") %>% 
  mutate(switch = replace_na(switch, 0))
  

distinct_count_clusters_base <- count_clusters_base %>% 
  group_by(cid_master) %>% 
  select(cid_master, maxcol, first_max, switch) %>%
  mutate(switch = abs(switch)) %>% 
  mutate(switch = if_else(switch >= 1, 1, 0)) %>% 
  mutate(cumsum_switch = cumsum(switch)) %>% 
  select(-switch) %>% 
  distinct() %>% 
  #mutate(cid_count = row_number()) %>% 
  ungroup() %>% 
  mutate(id=1:n())




#Spread All First Max and Max Cols
switch_clusters_base <- distinct_count_clusters_base %>% 
  ungroup() %>% 
  rename(switch = cumsum_switch) %>% 
  spread_chr(key_col = "switch",
             value_cols = c("maxcol"),
             sep = "_") %>% 
  #select(cid_master, id, first_max, everything() )
  select(-first_max)

#Recode All NA's to Blanks
switch_clusters_base <- sapply(switch_clusters_base, as.character)
switch_clusters_base[is.na(switch_clusters_base)] <- ''
switch_clusters_base <- as.data.frame(switch_clusters_base) 

#Make Data Table and Collapse Rows
setDT(switch_clusters_base)
switch_clusters_base <- switch_clusters_base[, lapply(.SD, paste0, collapse=""), by=cid_master]
switch_clusters_base <- as.data.frame(switch_clusters_base) 

#Unite Switches to a Pattern
switch_clusters <- switch_clusters_base %>% 
  unite(party_pat, 
        names(select(switch_clusters_base, starts_with("switch"))), 
        remove = FALSE) %>% 
  mutate(party_pat = str_replace_all(party_pat, "_*$", ""),
         party_pat = str_replace_all(party_pat, "^_*", ""),
         party_pat = str_replace_all(party_pat, "_{1,}", "_"),
         party_pat = str_replace_all(party_pat, "_+", "_")) %>% 
  mutate(cid_master = as.character(cid_master)) %>% 
  select(cid_master, party_pat)
  


#Get First and Last Max
first_last_max_clusters <- distinct_count_clusters_base %>% 
  group_by(cid_master) %>% 
  rename(switch = cumsum_switch) %>% 
  filter(switch == max(switch)) %>% 
  rename(final_max = maxcol) %>% 
  select(cid_master, first_max, final_max, switch)


#Make Final Clusters
final_clusters <- left_join(switch_clusters, first_last_max_clusters)




cluster_patterns <- left_join(cum_count_clusters, final_clusters)

#LOOK AT AES

df_joint <- left_join(df_refined_lme, final)



# 
# names(select(switch_clusters_base, starts_with("switch")))
# 
# mutate(third_max = if_else(is.na(third_max), '', as.character(third_max))) %>% 
#   unite(party_pat, c(first_max, second_max, third_max), remove = FALSE) %>% 
#   unite(final_max, c(second_max, third_max), remove = FALSE) %>% 
#   mutate(party_pat = str_replace(party_pat, "_$", ""),
#          final_max = str_replace(final_max, "_$", "")) %>% 
#   select(cid_master, party_pat, first_max, second_max, third_max, final_max) %>% 
#   mutate(final_max = str_replace(final_max, "[a-z]*_", ""))
# 
# 
# 
# switch_clusters_A <- switch_clusters_base %>% 
#   filter(cid_count == 1) %>% 
#   mutate(second_max = maxcol) %>% 
#   select(-cid_count, -maxcol)
# 
# switch_clusters_B <- switch_clusters_base %>% 
#   filter(cid_count == 2) %>% 
#   mutate(third_max = maxcol) %>% 
#   select(-cid_count, -maxcol)
# 
# 
# switch_clusters <- left_join(switch_clusters_A, switch_clusters_B) %>% 
#   mutate(third_max = if_else(is.na(third_max), '', as.character(third_max))) %>% 
#   unite(party_pat, c(first_max, second_max, third_max), remove = FALSE) %>% 
#   unite(final_max, c(second_max, third_max), remove = FALSE) %>% 
#   mutate(party_pat = str_replace(party_pat, "_$", ""),
#          final_max = str_replace(final_max, "_$", "")) %>% 
#   select(cid_master, party_pat, first_max, second_max, third_max, final_max) %>% 
#   mutate(final_max = str_replace(final_max, "[a-z]*_", ""))
# 
# 
# 
# stable_clusters_base <- count_clusters_base %>% 
#   filter(maxcol == first_max) %>% 
#   select(cid_master, maxcol, first_max) %>% 
#   distinct() %>% 
#   mutate(party_pat = first_max,
#          second_max = '',
#          third_max = '') %>% 
#   rename(final_max = maxcol) %>% 
#   select(cid_master, party_pat, first_max, second_max, third_max, final_max)
# 
# stable_clusters = anti_join(stable_clusters_base, 
#                             switch_clusters, by = "cid_master")
# 
# 
# final_clusters = bind_rows(stable_clusters, switch_clusters) 
