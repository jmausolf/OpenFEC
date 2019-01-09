####################################
## Load Contrib SOURCE
####################################

source("indiv_source.R")
source("hca_functions.R")


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
hca_df <- prepare_hca_df(dfocc, y1, y2)
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
ppi <- 300
fp <- "output/plots/"
png(paste0(fp,y1,"_",y2,"_optimal_clusters_plot.png"), width=7*ppi, height=5*ppi, res=ppi)
fviz_nbclust(df, FUN = hcut, method = "wss") +
  geom_vline(xintercept = 3, linetype = 2) +
  scale_y_continuous(limits = c(5000, 22000))
dev.off()



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
hca_df <- prepare_hca_df(dfocc, y1, y2)
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
ppi <- 300
fp <- "output/plots/"
png(paste0(fp,y1,"_",y2,"_optimal_clusters_plot.png"), width=7*ppi, height=5*ppi, res=ppi)
fviz_nbclust(df, FUN = hcut, method = "wss") +
geom_vline(xintercept = 3, linetype = 2) +
scale_y_continuous(limits = c(5000, 22000))
dev.off()


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
hca_df <- prepare_hca_df(dfocc, y1, y2)
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
ppi <- 300
fp <- "output/plots/"
png(paste0(fp,y1,"_",y2,"_optimal_clusters_plot.png"), width=7*ppi, height=5*ppi, res=ppi)
fviz_nbclust(df, FUN = hcut, method = "wss") +
  geom_vline(xintercept = 3, linetype = 2) +
  scale_y_continuous(limits = c(5000, 22000))
dev.off()

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
hca_df <- prepare_hca_df(dfocc, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_org, hca, y1, y2)


#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)


##---------------------------------
##Years Specification
y1 = 1992
y2 = 2002
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(dfocc, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_org, hca, y1, y2)


#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)


##---------------------------------
##Years Specification
y1 = 2004
y2 = 2012
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(dfocc, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_org, hca, y1, y2)


#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)






##---------------------------------
##Years Specification
y1 = 2010
y2 = 2018
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(dfocc, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_org, hca, y1, y2)


#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)


##---------------------------------
##Years Specification
y1 = 2014
y2 = 2018
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(dfocc, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_org, hca, y1, y2)


#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)





##---------------------------------
##Years Specification
y1 = 2004
y2 = 2012
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(dfocc, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_org, hca, y1, y2)


#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)






##---------------------------------
##Years Specification
y1 = 2014
y2 = 2018
gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", y1, "-", y2, "(AGNES HCA Using Ward)", sep = " ")
gfile = paste(y1, y2, sep = "_")


# Make Data Frame For Year
hca_df <- prepare_hca_df(dfocc, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


#Model
hca <- agnes(df, method = "ward")

#Post Cluster DF
post_df <- post_cluster_df(df_org, hca, y1, y2)


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
hca_df <- prepare_hca_df(dfocc, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]

#Model
hca <- agnes(df, method = "ward")


#Post Cluster DF
df_post_cluster <- post_cluster_df(df_org, hca, y1, y2)

#Make Plots
make_partisan_plot(hca, df_org, gtitle, gfile)


#Post DF Sub-DF's for Each Party

## join post cluster to dfocc3
dfocc3_hca_all <- left_join(dfocc3, df_post_cluster) 

## join post cluster to dfocc3
dfocc3_hca_dem <- left_join(dfocc3, df_post_cluster) %>% 
  filter(cluster == 3)
mean(dfocc3_hca_dem$partisan_score)
mean(dfocc3_hca_dem$median_ps)
mean(dfocc3_hca_dem$median_pid2)

## join post cluster to dfocc3
dfocc3_hca_rep <- left_join(dfocc3, df_post_cluster) %>% 
  filter(cluster == 1)
mean(dfocc3_hca_rep$partisan_score)
mean(dfocc3_hca_rep$median_ps)
mean(dfocc3_hca_rep$median_pid2)


## join post cluster to dfocc3
dfocc3_hca_oth <- left_join(dfocc3, df_post_cluster) %>% 
  filter(cluster == 2)
mean(dfocc3_hca_oth$partisan_score)
mean(dfocc3_hca_oth$median_ps)
mean(dfocc3_hca_oth$median_pid2)






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
hca_df <- prepare_hca_df(dfocc, y1, y2)
df_org <- hca_df[[1]]
df <- hca_df[[2]]

#Model
hca <- agnes(df, method = "ward")


#Post Cluster DF
df_post_cluster <- post_cluster_df(df_org, hca, y1, y2)

#Make Plots
make_partisan_plot_2004_2018(hca, df_org, gtitle, gfile)


#Post DF Sub-DF's for Each Party

## join post cluster to dfocc3
dfocc3_hca_all <- left_join(dfocc3, df_post_cluster)
mean(dfocc3_hca_all$partisan_score)
mean(dfocc3_hca_all$median_ps)
mean(dfocc3_hca_all$median_pid2)
mean(dfocc3_hca_all$var_pid2)
table(dfocc3_hca_all$pid2)


## join post cluster to dfocc3
dfocc3_hca_dem <- left_join(dfocc3, df_post_cluster) %>% 
  filter(cluster == 2)
mean(dfocc3_hca_dem$partisan_score)
mean(dfocc3_hca_dem$median_ps)
mean(dfocc3_hca_dem$median_pid2)
mean(dfocc3_hca_dem$var_pid2)
table(dfocc3_hca_dem$pid2)

## join post cluster to dfocc3
dfocc3_hca_rep <- left_join(dfocc3, df_post_cluster) %>% 
  filter(cluster == 1)
mean(dfocc3_hca_rep$partisan_score)
mean(dfocc3_hca_rep$median_ps)
mean(dfocc3_hca_rep$median_pid2)
mean(dfocc3_hca_rep$var_pid2)
table(dfocc3_hca_rep$pid2)


## join post cluster to dfocc3
dfocc3_hca_oth <- left_join(dfocc3, df_post_cluster) %>% 
  filter(cluster == 3)
mean(dfocc3_hca_oth$partisan_score)
mean(dfocc3_hca_oth$median_ps)
mean(dfocc3_hca_oth$median_pid2)
mean(dfocc3_hca_oth$var_pid2)
table(dfocc3_hca_oth$pid2)


