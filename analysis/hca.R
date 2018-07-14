####################################
## Load Contrib SOURCE
####################################

source("indiv_source.R")
source("hca_functions.R")




########################################
## Determine Model
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

# methods to assess
m <- c( "average", "single", "complete", "ward")
names(m) <- c( "average", "single", "complete", "ward")

# function to compute coefficient
ac <- function(x) {
  agnes(df, method = x)$ac
}

map_dbl(m, ac)

#diana coef
hcd <- diana(df)
hcd$dc




#Optimal Clusters
ppi <- 300
fp <- "output/plots/"
png(paste0(fp,y1,"_",y2,"_optimal_clusters_plot.png"), width=7*ppi, height=5*ppi, res=ppi)
fviz_nbclust(df, FUN = hcut, method = "wss")
dev.off()




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
## CLUSTERS FOR PLOTTING
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
post_df <- post_cluster_df(df_org, hca, y1, y2)


#Make Plots
make_partisan_plot_2004_2018(hca, df_org, gtitle, gfile)




############
## join post cluster to dfocc3
dfocc3_hca <- left_join(dfocc3, df_post_cluster) %>% 
  filter(cluster <= 2)

## join post cluster to dfocc3
dfocc3_hca_dem <- left_join(dfocc3, df_post_cluster) %>% 
  filter(cluster == 2)

## join post cluster to dfocc3
dfocc3_hca_rep <- left_join(dfocc3, df_post_cluster) %>% 
  filter(cluster == 1)

## join post cluster to dfocc3
dfocc3_hca_oth <- left_join(dfocc3, df_post_cluster) %>% 
  filter(cluster == 3)
