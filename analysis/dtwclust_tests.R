source("indiv_source.R")
source("indiv_vartab_varplot_functions.R")
source("indiv_partisan_functions.R")
source("hca400_functions.R")

library(zoo)


cycle_min = 1980
cycle_max = 2018
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")



df_filtered <- df_analysis %>% 
  filter(cycle >= cycle_min & cycle <= cycle_max ) %>% 
  #filter(cycle >= 1980 & cycle <= 2000 ) %>% 
  filter(!is.na(pid2),
         !is.na(partisan_score),
         !is.na(occ3),
         !is.na(occlevels)) %>% 
  #Group by Company (Collapse Across Cycles)
  #group_by(cid_master) 
  group_by(cycle, cid_master, occ3) %>% 
  summarize(var_pid2 = var(as.numeric(pid2), na.rm = TRUE),
            #var_ps = var(as.numeric(partisan_score), na.rm = TRUE),
            mean_pid2 = mean(as.numeric(pid2), na.rm = TRUE),
            #mean_pid3 = mean(as.numeric(pid3), na.rm = TRUE),
            #median_pid = median(as.numeric(pid), na.rm = TRUE),
            median_pid2 = median(as.numeric(pid2), na.rm = TRUE),
            #median_pid3 = median(as.numeric(pid3), na.rm = TRUE),
            mean_ps = mean(partisan_score, na.rm = TRUE),
            median_ps = median(partisan_score, na.rm = TRUE),
            mean_ps_mode = mean(as.numeric(partisan_score_mode), na.rm = TRUE), 
            mean_ps_min = mean(as.numeric(partisan_score_min), na.rm = TRUE),
            mean_ps_max = mean(as.numeric(partisan_score_max), na.rm = TRUE)
            #sum_pid_count = sum(as.numeric(party_id_count))
            
  )

#Spread OCC Columns
df_filtered <- df_filtered %>% 
  spread_chr(key_col = "occ3",
             value_cols = tail(names(df_filtered), -3),
             sep = "_") %>% 
  arrange(cycle)



#Extract CID MASTER
df_cid_master <- df_filtered %>% 
  ungroup() %>% 
  select(cid_master) %>% 
  arrange(cid_master)


#Prep and Standardize Data
df <- df_filtered %>% 
  arrange(cid_master, cycle) %>% 
  ungroup() %>% 
  select(-cid_master, cycle) 


#Backfill NA from Next Column
#i.e. use Manager/Other etc to fill missing exec / manager
#need to transpose first
#in this way, na fill uses relevant values from that firm-year instead of the whole dataset
  


dfT <- t(df)
dfT <- na.locf(dfT, fromLast = TRUE)

df <- as.data.frame(t(dfT))



#df <- as.data.frame(scale(df))

#df <- as.data.frame(sapply(df, as.numeric))
df <- bind_cols(df_cid_master, df)



#df <- bind_cols(df_cid_master, df)
# df <- scale(df)
# 
# df_matrix <- as.matrix(df_filtered) 

#Turn Each 
df_ts_matrix <- split(df, df$cid_master)

df <- as.data.frame(df_ts_matrix[[13]])
#print(df)
df <- as.data.frame(df) %>% 
  ungroup() %>% 
  select(-cycle, -cid_master)

#df <- scale(df)
df <- na.aggregate(df)
df <- Filter(function(x)!all(is.na(x)), df)
df <- na.omit(df)
table(is.na (df))

matrix_list <-  list()
for(i in seq_along(df_ts_matrix)){
  
  df <- as.data.frame(df_ts_matrix[[i]])
  df <- as.data.frame(df) %>% 
    ungroup() %>% 
    select(-cycle, -cid_master)
  
  #df <- scale(df)
  df <- na.aggregate(df)
  df <- Filter(function(x)!all(is.na(x)), df)
  df <- na.omit(df)
  #table(is.na (df))
  #print(table(is.na (df)))
  #df <- na.omit(df)
  matrix_list[[i]] <- data.matrix(df)
}


#Add Names
df_get_names <- df_filtered %>% 
  ungroup() %>% 
  select(cid_master) %>% 
  distinct() %>% 
  arrange(cid_master)

names(matrix_list) <- as.list(df_get_names)[[1]]


# 
# 
# # Making many repetitions
# pc.l2 <- tsclust(matrix_list, k = 3L,
#                  distance = "dtw", centroid = "pam",
#                  seed = 3247, trace = TRUE,
#                  control = partitional_control(nrep = 10L))
# 
# # Cluster validity indices
# sapply(pc.l2, cvi)
# 
# pc.l2[[1L]]@distmat
# 
# pc.l2[[4L]]@cluster
# 
# mvc <- tsclust(matrix_list, k = 3L, trace = TRUE,
#                             type = "hierarchical", 
#                             hierarchical_control(method = "all",
#                                                  distmat = pc.l2[[6L]]@distmat))
# 
# mvc
# mvc@cluster
# 
# 
# 
# mvc <- tsclust(matrix_list, k = 4L, trace = TRUE,
#                type = "hierarchical")
# 
# mvc
# mvc@cluster
# 
# 
# require(cluster)
# 
# hc.diana <- tsclust(matrix_list, type = "h", k = 4L,
#                     distance = "L2", trace = TRUE,
#                     control = hierarchical_control(method = diana))
# 
# plot(hc.diana, type = "sc")
# 
# 
# 
# # Using GAK distance
# mvc <- tsclust(matrix_list, k = 3L, distance = "gak", seed = 390,
#                args = tsclust_args(dist = list(sigma = 100)))
# 
# mvc
# mvc@cluster
# 
# plot(mvc)
# 



# dist_ts2 <- TSclust::diss(SERIES = t(matrix_list), METHOD = "DTWARP")
# dist_ts2

dist_ts <- TSclust::diss(SERIES = matrix_list, METHOD = "DTWARP")

#dist_ts <- TSclust::diss(SERIES = matrix_list, METHOD = "PACF")

  # 
# 
# hca <- agnes(dist_ts, method = "ward")
# sub_grp <- cutree(as.hclust(hca), k = 3, order_clusters_as_data = FALSE)
# sub_grp_df <- as.data.frame(sub_grp)
# df_post_cluster <- post_cluster_df(df_analysis, df_get_names, hca, cycle_min, cycle_max)
library(stats)
hca <- agnes(dist_ts, method = "ward")
hc <- as.hclust(hca)


df_labels <- stats::cutree(hc, k = 4) %>% # hclus <- cluster::pam(dist_ts, k = 2)$clustering has a similar result
  as.data.frame(.) %>%
  dplyr::rename(.,cluster = .) %>%
  tibble::rownames_to_column("cid_master")



df_post_cluster <- post_cluster_df(df_analysis, df_labels, hc, y1, y2)
df_party_clusters <- infer_partisanship(df_post_cluster) %>% 
  mutate(cycle_mean = as.character(cycle_mean))


method = "time_series_hca_ward"
base = TRUE
oth = TRUE

# join post cluster to df_analysis
df_hca_all <- left_join(df_analysis, df_party_clusters, 
                        by = c("cid_master" = "cid_master"))
mean(df_hca_all$partisan_score, na.rm = TRUE)
table(df_hca_all$pid2)


## join post cluster to df_analysis
df_hca_all_dem <- df_hca_all %>% 
  filter(cluster_party == "DEM")
mean(df_hca_all_dem$partisan_score, na.rm = TRUE)
table(df_hca_all_dem$pid2)

trans_dems <- df_hca_all_dem %>% select(cid_master, party_pat) %>% distinct()
trans_dems

## join post cluster to df_analysis
df_hca_all_rep <- df_hca_all %>% 
  filter(cluster_party == "REP")
mean(df_hca_all_rep$partisan_score, na.rm = TRUE)
table(df_hca_all_rep$pid2)

trans_reps <- df_hca_all_rep %>% select(cid_master, party_pat) %>% distinct()
trans_reps


df_hca_all_oth <- df_hca_all %>% 
  filter(cluster_party == "OTH")
mean(df_hca_all_oth$partisan_score, na.rm = TRUE)
table(df_hca_all_oth$pid2)

trans_oth <- df_hca_all_oth %>% select(cid_master, party_pat) %>% distinct()
trans_oth


## Make Graphs
source("indiv_mean_party_hca_loop.R")
