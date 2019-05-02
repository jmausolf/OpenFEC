library(DataCombine)
source("hca400_functions.R")
library(reshape2)
library(data.table)
library(nlme)


#Get Cluster and Total Counts
df_eval_clusters <- df_hca_cycles %>% 
  select(cid_master, cycle_mean, cycle_min, cycle_max, cluster_party, median_ps) %>% 
  mutate(cp = as.numeric(factor(cluster_party,
                     levels = c("DEM", "OTH", "REP")))) %>% 
  distinct() %>% 
  arrange(cid_master, cycle_mean) 

cluster_counts <- df_eval_clusters %>% 
  group_by(cid_master, cluster_party) %>% 
  summarise(cluster_count = n())

total_count <- df_eval_clusters %>% 
  group_by(cid_master) %>% 
  summarise(total_count = n())

#Get Dem Cluster Cumulative Sum
cum_counts_dem <- df_eval_clusters %>% 
  filter(cluster_party == "DEM") %>% 
  group_by(cid_master, cluster_party, cycle_mean) %>% 
  summarise(cluster_count = n()) %>% 
  mutate(cum_count_dem = cumsum(cluster_count)) %>% 
  ungroup() %>% 
  select(-cluster_party, -cluster_count)

#Get Rep Cluster Cumulative Sum
cum_counts_rep <- df_eval_clusters %>% 
  filter(cluster_party == "REP") %>% 
  group_by(cid_master, cluster_party, cycle_mean) %>% 
  summarise(cluster_count = n()) %>% 
  mutate(cum_count_rep = cumsum(cluster_count)) %>% 
  ungroup() %>% 
  select(-cluster_party, -cluster_count)

#Get Oth Cluster Cumulative Sum
cum_counts_oth <- df_eval_clusters %>% 
  filter(cluster_party == "OTH") %>% 
  group_by(cid_master, cluster_party, cycle_mean) %>% 
  summarise(cluster_count = n()) %>% 
  mutate(cum_count_oth = cumsum(cluster_count)) %>% 
  ungroup() %>% 
  select(-cluster_party, -cluster_count)

#Join Cumulative Sums and Fill NA
cum_count_clusters <- left_join(df_eval_clusters, cum_counts_dem) %>% 
  left_join(cum_counts_rep) %>% 
  left_join(cum_counts_oth) %>% 
  fill(cum_count_dem) %>% 
  fill(cum_count_rep) %>%  
  fill(cum_count_oth) %>% 
  mutate(cum_count_dem = replace_na(cum_count_dem, 0),
         cum_count_rep = replace_na(cum_count_rep, 0),
         cum_count_oth = replace_na(cum_count_oth, 0)) 

#Calculate Cluster Maximums
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

#Generate Change Score To Record a Change / Switch
#E.G. Back to Original Maxcol or Other Situation
count_clusters_base <- change(data = count_clusters_base, Var = 'max_col', 
                              TimeVar = 'cycle_mean', GroupVar = 'cid_master', 
                              NewVar = 'switch', slideBy = -1, type = "absolute") %>% 
  mutate(switch = replace_na(switch, 0))
  

#Recode Switch Direction and Magnitude to Binary
distinct_count_clusters_base <- count_clusters_base %>% 
  group_by(cid_master) %>% 
  select(cid_master, maxcol, first_max, switch) %>%
  mutate(switch = abs(switch)) %>% 
  mutate(switch = if_else(switch >= 1, 1, 0)) %>% 
  mutate(cumsum_switch = cumsum(switch)) %>% 
  select(-switch) %>% 
  distinct() %>% 
  ungroup() %>% 
  mutate(id=1:n())


#Spread All First Max and Max Cols
switch_clusters_base <- distinct_count_clusters_base %>% 
  ungroup() %>% 
  rename(switch = cumsum_switch) %>% 
  spread_chr(key_col = "switch",
             value_cols = c("maxcol"),
             sep = "_") %>% 
  select(-first_max)

#Recode All NA's to Blanks
switch_clusters_base <- sapply(switch_clusters_base, as.character)
switch_clusters_base[is.na(switch_clusters_base)] <- ''
switch_clusters_base <- as.data.frame(switch_clusters_base) 

#Make Data Table and Collapse Rows
setDT(switch_clusters_base)
switch_clusters_base <- switch_clusters_base[, lapply(.SD, paste0, collapse=""), by=cid_master]
switch_clusters_base <- as.data.frame(switch_clusters_base) 

#Unite Switches to a Party Pattern
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


#Make Final Clusters and Code Change Classes
final_clusters <- left_join(switch_clusters, first_last_max_clusters) %>% 
  mutate(party_class = "") %>% 
  #Stable Party Firms
  mutate(party_class = if_else((final_max == "rep" & switch == 0 ), "stable_rep", party_class),
         party_class = if_else((final_max == "dem" & switch == 0 ), "stable_dem", party_class),
         party_class = if_else((final_max == "oth" & switch == 0 ), "moderate_amphibians", party_class)) %>% 
  #Converted Amphibious Party Firms
  mutate(party_class = if_else((final_max == "rep" & switch >=1 & first_max != "dem"), 
                               "converted_amp_rep", party_class),
         party_class = if_else((final_max == "dem" & switch >=1 & first_max != "rep"), 
                               "converted_amp_dem", party_class)) %>%
  #Converted Opposite Party Firms
  mutate(party_class = if_else((final_max == "rep" & switch >=1 & first_max == "dem"), 
                               "converted_dem_rep", party_class),
         party_class = if_else((final_max == "dem" & switch >=1 & first_max == "rep"), 
                               "converted_rep_dem", party_class)) %>% 
  #Other Amphibious Party Firms
  mutate(party_class = if_else((final_max == "oth" & switch >=1 & first_max == "oth"), 
                               "true_amphibians", party_class),
         party_class = if_else((final_max == "oth" & switch >=1 & first_max == "dem"), 
                               "converted_dem_amp", party_class),
         party_class = if_else((final_max == "oth" & switch >=1 & first_max == "rep"), 
                               "converted_rep_amp", party_class)) %>%  

  #Make a Factor
  mutate(party_class = factor(party_class,
         labels = c("stable_rep", "converted_amp_rep", "converted_dem_rep",
                    "moderate_amphibians", "true_amphibians", 
                    "converted_rep_amp", "converted_dem_amp",
                    "stable_dem", "converted_amp_dem", "converted_rep_dem"
                    )
         ))
                    



#Join Final Clusters to Cumulative Counts
cluster_patterns <- left_join(cum_count_clusters, final_clusters)


#Make LME Model to Verify
cluster_pat_df <- cluster_patterns %>% 
  mutate(cycle = as.numeric(cycle_mean))

model1<- lme(cp ~ cycle + cum_count_dem + cum_count_rep + cum_count_oth + switch, 
             data=cluster_pat_df, random= ~cycle | cid_master, method="ML")
mcoefs <- as.data.frame(coef(model1))
mfit <- as.data.frame(fitted(model1))
mpred <- as.data.frame(predict(model1))

#Add Model Results to Final Clusters
df_refined_lme <- bind_cols(cluster_pat_df, mfit) %>% 
  rename(pred = `fitted(model1)`) %>% 
  group_by(cid_master) %>% 
  mutate(mean_pred = mean(pred, na.rm = TRUE)) %>% 
  select(-cycle)
