####################################
## Load Contrib SOURCE
####################################

source("indiv_source.R")
source("hca400_functions.R")
source("indiv_vartab_varplot_functions.R")
library(bbplot)

########################################
## Determine Model 1980-2002
########################################

##---------------------------------
##Years Specification
y1 = 1980
y2 = 2002
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(df_analysis, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]

#Agnes Evaluation Types
m <- c( "average", "weighted", "single", "complete", "ward")
names(m) <- c( "AGNES, UPGMA", "AGNES, WPGMA", "AGNES, Single Linkage", "AGNES, Complete Linkage", "AGNES, Ward's Method")

#Function to Compute Agnes Coef
ac <- function(x) {
  agnes(df, method = x)$ac
}

#Agnes Coefs
coef <- map_dbl(m, ac)
df_agnes <- data.frame(coef, stringsAsFactors=FALSE)
df_agnes


#Diana Coef
coef <-  diana(df)$dc
names(coef) <- c("Diana")
df_diana <- data.frame(coef, stringsAsFactors=FALSE)
df_diana

#Combined Coefs
coefs <- rbind(df_agnes, df_diana)
coefs_1980_2002 <- coefs %>% 
  rename("1980-2002" = "coef")


#Optimal Clusters
fp <- "output/plots/"
outfile <- paste0(fp,y1,"_",y2,"_optimal_clusters_plot.png")
g <- fviz_nbclust(df, FUN = hcut, method = "wss", linecolor=tab_blue) +
  bbc_style() +
  geom_vline(xintercept = 3, linetype = 2) +
  scale_y_continuous(limits = c(10000, 20500)) +
  theme(plot.title = element_text(hjust = 0.5, size=22)) +
  theme(axis.title = element_text(size = 18)) +
  xlab("Number of clusters, k") +
  labs(title = "Optimal Number of Clusters (1980-2002)") +
  theme(panel.grid.major.y=element_line(color="#cbcbcb"), 
        panel.grid.major.x=element_blank()) +
  geom_hline(yintercept = 10000, size = 1, colour="#333333")
finalise_plot(g, '', outfile, width_pixels=450,
              height_pixels=450, footer=FALSE)




########################################
## Determine Model 2004-2018
########################################

##---------------------------------
##Years Specification
y1 = 2004
y2 = 2018
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(df_analysis, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]

#Agnes Evaluation Types
m <- c( "average", "weighted", "single", "complete", "ward")
names(m) <- c( "AGNES, UPGMA", "AGNES, WPGMA", "AGNES, Single Linkage", "AGNES, Complete Linkage", "AGNES, Ward's Method")

#Function to Compute Agnes Coef
ac <- function(x) {
  agnes(df, method = x)$ac
}

#Agnes Coefs
coef <- map_dbl(m, ac)
df_agnes <- data.frame(coef, stringsAsFactors=FALSE)
df_agnes


#Diana Coef
coef <-  diana(df)$dc
names(coef) <- c("Diana")
df_diana <- data.frame(coef, stringsAsFactors=FALSE)
df_diana

#Combined Coefs
coefs <- rbind(df_agnes, df_diana)
coefs_2004_2018 <- coefs %>% 
          rename("2004-2018" = "coef")


#Optimal Clusters
fp <- "output/plots/"
outfile <- paste0(fp,y1,"_",y2,"_optimal_clusters_plot.png")
g <- fviz_nbclust(df, FUN = hcut, method = "wss", linecolor=tab_orange) +
  bbc_style() +
  geom_vline(xintercept = 3, linetype = 2) +
  scale_y_continuous(limits = c(37000, 65000)) +
  theme(plot.title = element_text(hjust = 0.5, size=22)) +
  theme(axis.title = element_text(size = 18)) +
  xlab("Number of clusters, k") +
  labs(title = "Optimal Number of Clusters (2004-2018)") +
  theme(panel.grid.major.y=element_line(color="#cbcbcb"), 
        panel.grid.major.x=element_blank()) +
  geom_hline(yintercept = 37000, size = 1, colour="#333333")
finalise_plot(g, '', outfile, width_pixels=450,
              height_pixels=450, footer=FALSE)


########################################
## Determine Model 2010-2018
########################################

##---------------------------------
##Years Specification
y1 = 2010
y2 = 2018
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(df_analysis, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]

#Agnes Evaluation Types
m <- c( "average", "weighted", "single", "complete", "ward")
names(m) <- c( "AGNES, UPGMA", "AGNES, WPGMA", "AGNES, Single Linkage", "AGNES, Complete Linkage", "AGNES, Ward's Method")

#Function to Compute Agnes Coef
ac <- function(x) {
  agnes(df, method = x)$ac
}

#Agnes Coefs
coef <- map_dbl(m, ac)
df_agnes <- data.frame(coef, stringsAsFactors=FALSE)
df_agnes


#Diana Coef
coef <-  diana(df)$dc
names(coef) <- c("Diana")
df_diana <- data.frame(coef, stringsAsFactors=FALSE)
df_diana

#Combined Coefs
coefs <- rbind(df_agnes, df_diana)
coefs_2010_2018 <- coefs %>% 
  rename("2010-2018" = "coef")


#Optimal Clusters
fp <- "output/plots/"
outfile <- paste0(fp,y1,"_",y2,"_optimal_clusters_plot.png")
g <- fviz_nbclust(df, FUN = hcut, method = "wss", linecolor=tab_blue) +
  bbc_style() +
  geom_vline(xintercept = 3, linetype = 2) +
  scale_y_continuous(limits = c(20000, 41000)) +
theme(plot.title = element_text(hjust = 0.5, size=22)) +
  theme(axis.title = element_text(size = 18)) +
  xlab("Number of clusters, k") +
  labs(title = "Optimal Number of Clusters (2010-2018)") +
  theme(panel.grid.major.y=element_line(color="#cbcbcb"), 
        panel.grid.major.x=element_blank()) +
  geom_hline(yintercept = 20000, size = 1, colour="#333333")
finalise_plot(g, '', outfile, width_pixels=450,
              height_pixels=450, footer=FALSE)



########################################
## Combined Model Determination
########################################

model_name <- rownames(coefs_2010_2018)
coefs_all_periods <- cbind(model_name, coefs_1980_2002, coefs_2004_2018, coefs_2010_2018) %>% 
  rename("Model, Method" = model_name)
coefs_all_periods

save_stargazer("output/tables/hca_coefs.tex",
               as.data.frame(coefs_all_periods), header=FALSE, type='latex',
               font.size = "footnotesize",
               title = "HCA Agglomerative (Agnes) or Divisive (Diana) Coefficients for Three Time Periods",
               label = "tab:model_coefs",
               summary = FALSE,
               rownames = FALSE)


########################################
## Model Example and Visual
########################################

##---------------------------------
##Years Specification
y1 = 1980
y2 = 1990
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(df_analysis, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_analysis, df_org, hca, y1, y2)


#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)


##---------------------------------
##Years Specification
y1 = 1992
y2 = 2002
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(df_analysis, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_analysis, df_org, hca, y1, y2)


#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)


##---------------------------------
##Years Specification
y1 = 2004
y2 = 2012
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(df_analysis, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_analysis, df_org, hca, y1, y2)


#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)






##---------------------------------
##Years Specification
y1 = 2010
y2 = 2018
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(df_analysis, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_analysis, df_org, hca, y1, y2)


#Make Plots
source("hca_functions.R")
make_partisan_plot(hca, df_org, gtitle, gfile)


##---------------------------------
##Years Specification
y1 = 2014
y2 = 2018
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(df_analysis, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_analysis, df_org, hca, y1, y2)


#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)





##---------------------------------
##Years Specification
y1 = 2004
y2 = 2012
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(df_analysis, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_analysis, df_org, hca, y1, y2)


#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)






##---------------------------------
##Years Specification
y1 = 2014
y2 = 2018
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(df_analysis, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_analysis, df_org, hca, y1, y2)


#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)






########################################
## CLUSTERS FOR PLOTTING 2010-2018
########################################

##---------------------------------
##Years Specification
y1 = 2010
y2 = 2018
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")

# Make Data Frame For Year
hca_df <- prepare_hca_df(df_analysis, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]

#Model
hca <- agnes(df, method = "ward")


#Post Cluster DF
df_post_cluster <- post_cluster_df(df_analysis, df_org, hca, y1, y2)

#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)


#Post DF Sub-DF's for Each Party

## join post cluster to df_analysis
df_hca_1018_all <- left_join(df_analysis, df_post_cluster)
mean(df_hca_1018_all$partisan_score, na.rm = TRUE)
mean(df_hca_1018_all$median_ps)
mean(df_hca_1018_all$median_pid2)
mean(df_hca_1018_all$var_pid2)
table(df_hca_1018_all$pid2)

## join post cluster to df_analysis
df_hca_1018_dem <- left_join(df_analysis, df_post_cluster) %>% 
  filter(cluster == 3)
mean(df_hca_1018_dem$partisan_score, na.rm = TRUE)
mean(df_hca_1018_dem$median_ps)
mean(df_hca_1018_dem$median_pid2)
mean(df_hca_1018_dem$var_pid2)
table(df_hca_1018_dem$pid2)

## join post cluster to df_analysis
df_hca_1018_rep <- left_join(df_analysis, df_post_cluster) %>% 
  filter(cluster == 1)
mean(df_hca_1018_rep$partisan_score, na.rm = TRUE)
mean(df_hca_1018_rep$median_ps)
mean(df_hca_1018_rep$median_pid2)
mean(df_hca_1018_rep$var_pid2)
table(df_hca_1018_rep$pid2)


## join post cluster to df_analysis
df_hca_1018_oth <- left_join(df_analysis, df_post_cluster) %>% 
  filter(cluster == 2)
mean(df_hca_1018_oth$partisan_score, na.rm = TRUE)
mean(df_hca_1018_oth$median_ps)
mean(df_hca_1018_oth$median_pid2)
mean(df_hca_1018_oth$var_pid2)
table(df_hca_1018_oth$pid2)






########################################
## CLUSTERS FOR PLOTTING 2004-2018
########################################

##---------------------------------
##Years Specification
y1 = 2004
y2 = 2018
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")

# Make Data Frame For Year
hca_df <- prepare_hca_df(df_analysis, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]

#Model
hca <- agnes(df, method = "ward")


#Post Cluster DF
df_post_cluster <- post_cluster_df(df_analysis, df_org, hca, y1, y2)

#Make Plots
make_partisan_plot_2004_2018(hca, df_org, gtitle, gfile)


#Post DF Sub-DF's for Each Party

## join post cluster to df_analysis
df_hca_0418_all <- left_join(df_analysis, df_post_cluster)
mean(df_hca_0418_all$partisan_score, na.rm = TRUE)
mean(df_hca_0418_all$median_ps)
mean(df_hca_0418_all$median_pid2)
mean(df_hca_0418_all$var_pid2)
table(df_hca_0418_all$pid2)

df_hca_0418_all_firms <- df_hca_0418_all %>% 
  select(cid_master, cluster, var_pid2, mean_pid2, median_pid2, mean_ps, median_ps, mean_ps_mode, mean_ps_min, mean_ps_max) %>% 
  distinct()


##LOOK INTO PLOTTING MEDIAN VS MEAN PID/PS

## join post cluster to df_analysis
df_hca_0418_dem <- left_join(df_analysis, df_post_cluster) %>% 
  filter(cluster == 3)
mean(df_hca_0418_dem$partisan_score, na.rm = TRUE)
mean(df_hca_0418_dem$median_ps)
mean(df_hca_0418_dem$median_pid2)
mean(df_hca_0418_dem$var_pid2)
table(df_hca_0418_dem$pid2)

## join post cluster to df_analysis
df_hca_0418_rep <- left_join(df_analysis, df_post_cluster) %>% 
  filter(cluster == 2)
mean(df_hca_0418_rep$partisan_score, na.rm = TRUE)
mean(df_hca_0418_rep$median_ps)
mean(df_hca_0418_rep$median_pid2)
mean(df_hca_0418_rep$var_pid2)
table(df_hca_0418_rep$pid2)


## join post cluster to df_analysis
df_hca_0418_oth <- left_join(df_analysis, df_post_cluster) %>% 
  filter(cluster == 1)
mean(df_hca_0418_oth$partisan_score, na.rm = TRUE)
mean(df_hca_0418_oth$median_ps)
mean(df_hca_0418_oth$median_pid2)
mean(df_hca_0418_oth$var_pid2)
table(df_hca_0418_oth$pid2)


