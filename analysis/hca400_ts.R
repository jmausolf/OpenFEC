####################################
## Load Contrib SOURCE
####################################

source("hca400_ts_functions.R")
source("hca400_ts_base_features.R")

#TODO
#https://academic.oup.com/bioinformatics/article/22/12/1540/207339
#pvclust bootstrapping explore

########################################
## HCA TS Model 0 - B0, A1
########################################

##---------------------------------
##Years Specification
y1 = 1980
y2 = 2018
gtitle = paste("Hiearchical Time Series Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


## Select Base Features
df_base0 <- base_features0(df_analysis, y1, y2)

## Prepare Additional Features (Polarization/Similarity)
#Reverse the Other/All Conversion for Graphing Pre 2004
df_polarization_prep_1 <- df_polarization %>% 
  mutate(occ3 = as.character(occ)) %>% 
  mutate(occ3 = ifelse(occ3 == "ALL" & cycle < 2004, "OTHERS", as.character(occ3))) %>%
  filter(occ3 != "ALL") %>% 
  mutate(occ3 = factor(occ3,
                       levels = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
  filter(!is.na(occ3)) %>% 
  select(-occ)

## Make Matrix of Multivariate Time Series
set.seed(1)
m0_hca_prep <- prepare_hca_ts_df(df_base0, df_polarization_prep_1, y1, y2)
m0 <- m0_hca_prep$matrix_list

## HCA Input DF for Post Analysis
m0_prep_df <- m0_hca_prep$prep_df


##Calculate TSClust Dissimilarity Matrix 
## "DTWARP" Dynamic Time Warping method. See diss.DTWARP.
## https://www.rdocumentation.org/packages/TSclust/versions/1.2.4/topics/diss
m0_dist_ts <- TSclust::diss(SERIES = m0, METHOD = "DTWARP")


## Run HCA on MV TS Diss Matrix
hca0 <- agnes(m0_dist_ts, method = "ward")
hc0 <- as.hclust(hca0)
dend0 <- as.dendrogram(hc0)


##Make HCA Plot
df_post_cluster_m0 <- make_partisan_plot_tsclust(hc0, m0_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = "NONE")

##Adjust HCA Plot Visual Colors to Match Clusters
party_order = c("REP", "OTH", "DEM")
df_post_cluster_m0 <- make_partisan_plot_tsclust(hc0, m0_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = party_order)

df_clust_simple_m0 <- df_post_cluster_m0 %>% 
  select(cid_master, cluster_party) %>% 
  distinct()



########################################
## HCA TS Model 1 - B1, A1
########################################

##---------------------------------
##Years Specification
y1 = 1980
y2 = 2018
gtitle = paste("Hiearchical Time Series Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


## Select Base Features
df_base1 <- base_features1(df_analysis, y1, y2)

## Prepare Additional Features (Polarization/Similarity)
#Reverse the Other/All Conversion for Graphing Pre 2004
df_polarization_prep_1 <- df_polarization %>% 
  mutate(occ3 = as.character(occ)) %>% 
  mutate(occ3 = ifelse(occ3 == "ALL" & cycle < 2004, "OTHERS", as.character(occ3))) %>%
  filter(occ3 != "ALL") %>% 
  mutate(occ3 = factor(occ3,
                        levels = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
  filter(!is.na(occ3)) %>% 
  select(-occ)

## Make Matrix of Multivariate Time Series
set.seed(1)
m1_hca_prep <- prepare_hca_ts_df(df_base1, df_polarization_prep_1, y1, y2)
m1 <- m1_hca_prep$matrix_list

## HCA Input DF for Post Analysis
m1_prep_df <- m1_hca_prep$prep_df


##Calculate TSClust Dissimilarity Matrix 
## "DTWARP" Dynamic Time Warping method. See diss.DTWARP.
## https://www.rdocumentation.org/packages/TSclust/versions/1.2.4/topics/diss
m1_dist_ts <- TSclust::diss(SERIES = m1, METHOD = "DTWARP")


## Run HCA on MV TS Diss Matrix
hca1 <- agnes(m1_dist_ts, method = "ward")
hc1 <- as.hclust(hca1)
dend1 <- as.dendrogram(hc1)


##Make HCA Plot
df_post_cluster_m1 <- make_partisan_plot_tsclust(hc1, m1_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = "NONE")

##Adjust HCA Plot Visual Colors to Match Clusters
party_order = c("REP", "OTH", "DEM")
df_post_cluster_m1 <- make_partisan_plot_tsclust(hc1, m1_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = party_order)

df_clust_simple_m1 <- df_post_cluster_m1 %>% 
  select(cid_master, cluster_party) %>% 
  distinct()


# 
# ########################################
# ## HCA TS Model 2 - B0, A2
# ########################################
# 
# ##---------------------------------
# ##Years Specification
# y1 = 1980
# y2 = 2018
# gtitle = paste("Hiearchical Time Series Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
# gfile = paste(y1, y2, sep = "_")
# 
# 
# ## Select Base Features
# df_base0 <- base_features0(df_analysis, y1, y2)
# 
# ## Prepare Additional Features (Polarization/Similarity)
# #Reverse the Other/All Conversion for Graphing Pre 2004
# df_polarization_prep_2 <- df_polarization %>% 
#   mutate(occ3 = as.character(occ)) %>% 
#   mutate(occ3 = ifelse(occ3 == "ALL" & cycle < 2004, "OTHERS", as.character(occ3))) %>%
#   filter(occ3 != "ALL") %>% 
#   mutate(occ3 = factor(occ3,
#                        levels = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
#   filter(!is.na(occ3)) %>% 
#   select(-occ, -kurtosis_pid, -kurtosis_ps)
# 
# ## Make Matrix of Multivariate Time Series
# set.seed(1)
# m2_hca_prep <- prepare_hca_ts_df(df_base0, df_polarization_prep_2, y1, y2)
# m2 <- m2_hca_prep$matrix_list
# 
# ## HCA Input DF for Post Analysis
# m2_prep_df <- m2_hca_prep$prep_df
# 
# 
# ##Calculate TSClust Dissimilarity Matrix 
# ## "DTWARP" Dynamic Time Warping method. See diss.DTWARP.
# ## https://www.rdocumentation.org/packages/TSclust/versions/1.2.4/topics/diss
# m2_dist_ts <- TSclust::diss(SERIES = m2, METHOD = "DTWARP")
# 
# 
# ## Run HCA on MV TS Diss Matrix
# hca2 <- agnes(m2_dist_ts, method = "ward")
# hc2 <- as.hclust(hca2)
# dend2 <- as.dendrogram(hc2)
# 
# 
# ##Make HCA Plot
# df_post_cluster_m2 <- make_partisan_plot_tsclust(hc2, m2_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = "NONE")
# 
# ##Adjust HCA Plot Visual Colors to Match Clusters
# party_order = c("OTH", "REP", "DEM")
# df_post_cluster_m2 <- make_partisan_plot_tsclust(hc2, m2_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = party_order)
# 
# df_clust_simple_m2 <- df_post_cluster_m2 %>% 
#   select(cid_master, cluster_party) %>% 
#   distinct()
# 


# 
# 
# ########################################
# ## HCA TS Model 3 - B1, A2
# ########################################
# 
# ##---------------------------------
# ##Years Specification
# y1 = 1980
# y2 = 2018
# gtitle = paste("Hiearchical Time Series Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
# gfile = paste(y1, y2, sep = "_")
# 
# 
# ## Select Base Features
# df_base1 <- base_features1(df_analysis, y1, y2)
# 
# ## Prepare Additional Features (Polarization/Similarity)
# #Reverse the Other/All Conversion for Graphing Pre 2004
# df_polarization_prep_2 <- df_polarization %>% 
#   mutate(occ3 = as.character(occ)) %>% 
#   mutate(occ3 = ifelse(occ3 == "ALL" & cycle < 2004, "OTHERS", as.character(occ3))) %>%
#   filter(occ3 != "ALL") %>% 
#   mutate(occ3 = factor(occ3,
#                        levels = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
#   filter(!is.na(occ3)) %>% 
#   select(-occ, -kurtosis_pid, -kurtosis_ps)
# 
# ## Make Matrix of Multivariate Time Series
# set.seed(1)
# m3_hca_prep <- prepare_hca_ts_df(df_base1, df_polarization_prep_2, y1, y2)
# m3 <- m3_hca_prep$matrix_list
# 
# ## HCA Input DF for Post Analysis
# m3_prep_df <- m3_hca_prep$prep_df
# 
# 
# ##Calculate TSClust Dissimilarity Matrix 
# ## "DTWARP" Dynamic Time Warping method. See diss.DTWARP.
# ## https://www.rdocumentation.org/packages/TSclust/versions/1.2.4/topics/diss
# m3_dist_ts <- TSclust::diss(SERIES = m3, METHOD = "DTWARP")
# 
# 
# ## Run HCA on MV TS Diss Matrix
# hca3 <- agnes(m3_dist_ts, method = "ward")
# hc3 <- as.hclust(hca3)
# dend3 <- as.dendrogram(hc3)
# 
# 
# ##Make HCA Plot
# df_post_cluster_m3 <- make_partisan_plot_tsclust(hc3, m3_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = "NONE")
# 
# ##Adjust HCA Plot Visual Colors to Match Clusters
# party_order = c("OTH", "REP", "DEM")
# df_post_cluster_m3 <- make_partisan_plot_tsclust(hc3, m3_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = party_order)
# 
# df_clust_simple_m3 <- df_post_cluster_m3 %>% 
#   select(cid_master, cluster_party) %>% 
#   distinct()
# 
# 



########################################
## HCA TS Model 4 - B2, A3
########################################

##---------------------------------
##Years Specification
y1 = 1980
y2 = 2018
gtitle = paste("Hiearchical Time Series Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


## Select Base Features
df_base2 <- base_features2(df_analysis, y1, y2)
#df_base3 <- base_features3(df_analysis, y1, y2)

## Prepare Additional Features (Polarization/Similarity)
#Reverse the Other/All Conversion for Graphing Pre 2004
df_polarization_prep_3 <- df_polarization %>% 
  mutate(occ3 = as.character(occ)) %>% 
  mutate(occ3 = ifelse(occ3 == "ALL" & cycle < 2004, "OTHERS", as.character(occ3))) %>%
  filter(occ3 != "ALL") %>% 
  mutate(occ3 = factor(occ3,
                       levels = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
  filter(!is.na(occ3)) %>% 
  select(-occ, -kurtosis_pid, -kurtosis_ps, -var_pid, -var_ps)

## Make Matrix of Multivariate Time Series
set.seed(1)
m4_hca_prep <- prepare_hca_ts_df(df_base2, df_polarization_prep_3, y1, y2)
m4 <- m4_hca_prep$matrix_list

## HCA Input DF for Post Analysis
m4_prep_df <- m4_hca_prep$prep_df


##Calculate TSClust Dissimilarity Matrix 
## "DTWARP" Dynamic Time Warping method. See diss.DTWARP.
## https://www.rdocumentation.org/packages/TSclust/versions/1.2.4/topics/diss
m4_dist_ts <- TSclust::diss(SERIES = m4, METHOD = "DTWARP")


## Run HCA on MV TS Diss Matrix
hca4 <- agnes(m4_dist_ts, method = "ward")
hc4 <- as.hclust(hca4)
dend4 <- as.dendrogram(hc4)


##Make HCA Plot
df_post_cluster_m4 <- make_partisan_plot_tsclust(hc4, m4_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = "NONE")

##Adjust HCA Plot Visual Colors to Match Clusters
party_order = c("OTH", "REP", "DEM")
df_post_cluster_m4 <- make_partisan_plot_tsclust(hc4, m4_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = party_order)

df_clust_simple_m4 <- df_post_cluster_m4 %>% 
  select(cid_master, cluster_party) %>% 
  distinct()


# 
# 
# 
# ########################################
# ## HCA TS Model 5 - B2, A4
# ########################################
# 
# ##---------------------------------
# ##Years Specification
# y1 = 1980
# y2 = 2018
# gtitle = paste("Hiearchical Time Series Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
# gfile = paste(y1, y2, sep = "_")
# 
# 
# ## Select Base Features
# df_base2 <- base_features2(df_analysis, y1, y2)
# #df_base3 <- base_features3(df_analysis, y1, y2)
# 
# ## Prepare Additional Features (Polarization/Similarity)
# #Reverse the Other/All Conversion for Graphing Pre 2004
# df_polarization_prep_4 <- df_polarization %>% 
#   mutate(occ3 = as.character(occ)) %>% 
#   mutate(occ3 = ifelse(occ3 == "ALL" & cycle < 2004, "OTHERS", as.character(occ3))) %>%
#   filter(occ3 != "ALL") %>% 
#   mutate(occ3 = factor(occ3,
#                        levels = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
#   filter(!is.na(occ3)) %>% 
#   select(cycle, cid_master, occ3, skewness_pid, skewness_ps)
# 
# 
# ## Make Matrix of Multivariate Time Series
# set.seed(1)
# m5_hca_prep <- prepare_hca_ts_df(df_base2, df_polarization_prep_4, y1, y2)
# m5 <- m5_hca_prep$matrix_list
# 
# ## HCA Input DF for Post Analysis
# m5_prep_df <- m5_hca_prep$prep_df
# 
# 
# ##Calculate TSClust Dissimilarity Matrix 
# ## "DTWARP" Dynamic Time Warping method. See diss.DTWARP.
# ## https://www.rdocumentation.org/packages/TSclust/versions/1.2.4/topics/diss
# m5_dist_ts <- TSclust::diss(SERIES = m5, METHOD = "DTWARP")
# 
# 
# ## Run HCA on MV TS Diss Matrix
# hca5 <- agnes(m5_dist_ts, method = "ward")
# hc5 <- as.hclust(hca5)
# dend5 <- as.dendrogram(hc5)
# 
# 
# ##Make HCA Plot
# df_post_cluster_m5 <- make_partisan_plot_tsclust(hc5, m5_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = "NONE")
# 
# ##Adjust HCA Plot Visual Colors to Match Clusters
# party_order = c("OTH", "REP", "DEM")
# df_post_cluster_m5 <- make_partisan_plot_tsclust(hc5, m5_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = party_order)
# 
# df_clust_simple_m5 <- df_post_cluster_m5 %>% 
#   select(cid_master, cluster_party) %>% 
#   distinct()
# 
# 
# 
# 
# 
# 
# 
