####################################
## Load Contrib SOURCE
####################################

source("hca400_ts_functions.R")

########################################
## HCA TS Model
########################################

##---------------------------------
##Years Specification
y1 = 1980
y2 = 2018
gtitle = paste("Hiearchical Time Series Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


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
set.seed(524)
m1_hca_prep <- prepare_hca_ts_df(df_analysis, df_polarization_prep_1, y1, y2)
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
df_post_cluster <- make_partisan_plot_tsclust(hc1, m1_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = "NONE")

##Adjust HCA Plot Visual Colors to Match Clusters
party_order = c("REP", "OTH", "DEM")
df_post_cluster <- make_partisan_plot_tsclust(hc1, m1_prep_df, y1, y2, K=3, gtitle, gfile, party_viz = party_order)



## Make Graphs From Results
method = "time_series_hca_ward_k3_polar_m1"
base = TRUE
oth = TRUE

# join post cluster to df_analysis
df_hca_all <- df_post_cluster
mean(df_hca_all$partisan_score, na.rm = TRUE)
table(df_hca_all$pid2)


## join post cluster to df_analysis
df_hca_all_dem <- df_hca_all %>% 
  filter(cluster_party == "DEM")
mean(df_hca_all_dem$partisan_score, na.rm = TRUE)
table(df_hca_all_dem$pid2)


## join post cluster to df_analysis
df_hca_all_rep <- df_hca_all %>% 
  filter(cluster_party == "REP")
mean(df_hca_all_rep$partisan_score, na.rm = TRUE)
table(df_hca_all_rep$pid2)


df_hca_all_oth <- df_hca_all %>% 
  filter(cluster_party == "OTH")
mean(df_hca_all_oth$partisan_score, na.rm = TRUE)
table(df_hca_all_oth$pid2)

## Make Graphs
source("indiv_mean_party_hca_loop.R")

