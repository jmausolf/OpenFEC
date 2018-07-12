####################################
## Load Contrib SOURCE
####################################

source("indiv_source.R")

## Load Additional Libraries
library(cluster)   
library(factoextra)
library(dendextend)
library(circlize)
library(dendsort)
library(heatmap.plus)
library(RColorBrewer)
library(forcats)



########################################
## Data Preparation
########################################



########################################
## Functions
########################################


prepare_hca_df <- function(input_df, cycle_min = 1980, cycle_max = 2020){
  df_filtered <- input_df %>% 
    filter(cycle >= cycle_min & cycle <= cycle_max ) %>% 
    
    #Group by Company (Collapse Across Cycles)
    group_by(cid_master) %>%
    
    #Features
    summarize(mean_partisan_score = mean(partisan_score, na.rm = TRUE),
                median_partisan_score = median(partisan_score, na.rm = TRUE))

    
  #Convert to Format Needed for HCA (and Graphs)
  df <- as.data.frame(df_filtered)
    
  #Add company names as rownames
  rownames(df) <- df$cid_master
  df$cid_master <- NULL

  #Prep and Standardize Data
  df <- na.omit(df)
  df <- scale(df)
  
  out_dfs <- list(df_filtered, df)
  return(out_dfs)
}



rejoin_clusters_data <- function(df_filtered,
                                 hca_model, 
                                 K=4, 
                                 shapesvec=c("15", "0", "1", "19"),
                                 colorsvec=c("#BF1200", "#BF1200", "#2129B0", "#2129B0")
) {
  
  #require("lazyeval")
  #TODO get shape/col vects to pass to fct_recode
  
  #TODO
  #Assert if length of shapes, colors are not each k
  
  #Cut Tree into K Groups 
  sub_grp <- cutree(as.hclust(hca_model), k = K, order_clusters_as_data = FALSE)
  
  #Sort Properly (For Post Vectors)
  sub_grp_df <- as.data.frame(sub_grp)
  sub_grp_df$cid_master <- rownames(sub_grp_df)
  sub_grp_df <- sub_grp_df %>% arrange(cid_master)
  sub_grp_sorted <- sub_grp_df$sub_grp
  
  #s <- shapes
  #c <- colors
  
  # s1 = shapesvec[1]
  # s2 = shapesvec[2]
  # s3 = shapesvec[3]
  # s4 = shapesvec[4]
  
  #See what groups original data is in
  dfclust <- df_filtered %>%
    mutate(cluster = sub_grp_sorted) %>% 
    arrange(cluster) %>% 
    mutate(shapes = as.numeric(as.character(fct_recode(as.factor(cluster),
                                                       "15" = "1",
                                                       "0" = "2",
                                                       "1" = "3",
                                                       "19" = "4"
    )))) %>% 
    mutate(colors = as.character(fct_recode(as.factor(cluster),
                                            "#BF1200" = "1",
                                            "#BF1200" = "2",
                                            "#2129B0" = "3",
                                            "#2129B0" = "4"
    )))
  
  return(dfclust)
}




make_partisan_plot <- function(hca_model, df_filtered, gtitle="my graph title", gtyp="graph_spec"){
  
  #Rejoin HCA Clusters to Original Data for Better Plots
  dfclust <- rejoin_clusters_data(df_filtered, hca_model)
  
  #Shape and Color Vectors
  shapevec <- dfclust$shapes
  colorvec <- dfclust$colors
  
  
  #Specify Graph Options
  dend <- as.dendrogram(hca_model) %>% 
    color_branches(k = 4, col=c("#BF1200", "#BF1200", "#2129B0", "#2129B0")) %>% 
    color_labels(k = 4, col=c("#BF1200", "#BF1200", "#2129B0", "#2129B0")) %>% 
    assign_values_to_leaves_nodePar(value=shapevec, "pch") %>% 
    assign_values_to_leaves_nodePar(value=colorvec, "col") 
  
  
  
  #Specs
  ppi <- 600
  fp <- "output/plots/"
  modnm <- deparse(substitute(hca_model))
  
  
  #Horiz Graph
  hz <- function(gtitle){
    par(mfrow = c(1,1))
    par(mar=c(3,4,1,6)) # set margins
    labels_cex(dend) <- 0.4
    plot(dend, horiz  = TRUE, cex = 0.5)
    legend("bottomleft", 
           legend = c("Polorized Democrat" , "Lean Democrat" , "Lean Republican" , "Polorized Republican"), 
           col = c("#2129B0", "#2129B0", "#BF1200", "#BF1200"), 
           pch = c(19,1,0,15), bty = "n",  pt.cex = 1.5, cex = 0.8 , 
           text.col = "black", horiz = FALSE, inset = c(0.0, 0.0))
    title(main = gtitle)      
  }
  
  png(paste0(fp,modnm,"_",gtyp,"_horiz_plot.png"), width=11.5*ppi, height=8*ppi, res=ppi)
  hz(gtitle)
  dev.off()
  
  pdf(paste0(fp,modnm,"_",gtyp,"_horiz_plot.pdf"), width=11.5, height=8)
  hz(gtitle)
  dev.off()
  
  
  #Combined Graph
  
  cb <- function(gtitle){
    par(mfrow = c(1,2))
    
    #Verticle Dend Graph
    par(mar=c(1,3,1,0)) # set margins
    plot(dend, cex = 0.5, leaflab = "none")
    legend("topleft",
           legend = c("Polorized Democrat" , "Lean Democrat" , "Lean Republican" , "Polorized Republican"),
           col = c("#2129B0", "#2129B0", "#BF1200", "#BF1200"),
           pch = c(19,1,0,15), bty = "n",  pt.cex = 1.5, cex = 0.8 ,
           text.col = "black", horiz = FALSE, inset = c(0.0, 0.05))
    
    #Horz
    par(mar=c(2,0,1,8)) # set margins
    labels_cex(dend) <- 0.5
    plot(dend, horiz  = TRUE, cex = 0.5)
    par(oma=c(0,0,2,0))
    title(main = gtitle, outer=TRUE)
  }
  
  png(paste0(fp,modnm,"_",gtyp,"_combined_plot.png"), width=11.5*ppi, height=8*ppi, res=ppi)
  cb(gtitle)
  dev.off()
  
  pdf(paste0(fp,modnm,"_",gtyp,"_combined_plot.pdf"), width=11.5, height=8)
  cb(gtitle)
  dev.off()
  
  
}



########################################
## Model Example and Visual
########################################

##1980-1990

hca_df <- prepare_hca_df(dfocc3, 1980, 1990)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


# Dissimilarity matrix
d <- dist(df, method = "euclidean")

#Basic Model
hc3 <- agnes(df, method = "ward")

#Make Plots
make_partisan_plot(hc3, df_org, "Hiearchical Cluster Model Partisan Polarization 1980-1990 (AGNES HCA Using Ward)", 
                   "1980_1990" )




##1992-2000

hca_df <- prepare_hca_df(dfocc3, 1992, 2000)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


# Dissimilarity matrix
d <- dist(df, method = "euclidean")

#Basic Model
hc3 <- agnes(df, method = "ward")

#Make Plots
make_partisan_plot(hc3, df_org, "Hiearchical Cluster Model Partisan Polarization 1992-2000 (AGNES HCA Using Ward)", 
                   "1992_2000" )




##2002-2008

hca_df <- prepare_hca_df(dfocc3, 2002, 2008)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


# Dissimilarity matrix
d <- dist(df, method = "euclidean")

#Basic Model
hc3 <- agnes(df, method = "ward")

#Make Plots
make_partisan_plot(hc3, df_org, "Hiearchical Cluster Model Partisan Polarization 2002 - 2008 (AGNES HCA Using Ward)", 
                   "2002_2008" )



##2002-2008

hca_df <- prepare_hca_df(dfocc3, 2010, 2018)
df_org <- hca_df[[1]]
df <- hca_df[[2]]


# Dissimilarity matrix
d <- dist(df, method = "euclidean")

#Basic Model
hc3 <- agnes(df, method = "ward")

#Make Plots
make_partisan_plot(hc3, df_org, "Hiearchical Cluster Model Partisan Polarization 2010 - 2018 (AGNES HCA Using Ward)", 
                   "2010_2018" )










########################################
## SCRAP
########################################
################################
## Sorted?
##################################

# dd <- dendsort(as.dendrogram(hc3), type="min")
# hc_sorted  <- as.hclust(dd)
# 
# plot(hc_sorted, cex = 0.6)
# rect.hclust(hc_sorted, k = 4, border = 2:5)
# 
# plot(hc3, cex = 0.6)
# rect.hclust(hc3, k = 4, border = 2:5)
# 
# 
# 
# 
# plot(hc_sorted, cex = 0.6, horiz)
# rect.hclust(hc_sorted, k = 4, border = 2:5)
# 
# #sort by average distance
# #plot(dendsort(hc5, type="average"), cex = 0.6)
# plot(dendsort(hc5, type="min", isReverse=TRUE), cex = 0.6)
# rect.hclust(dendsort(hc5, type="min", isReverse=TRUE), k = 4, border = 2:5)
# 
# 
# plot(dendsort(hc3, type="min", isReverse=TRUE), cex = 0.6)











# # plot the radial plot
# par(mar = rep(0,4))
# circlize_dendrogram(dend, dend_track_height = 0.5) 
# circlize_dendrogram(dend, labels_track_height = 0.1, dend_track_height = .3)
# 
# 
# 
# #CUT TREE
# ct <- cutree(dend, k = 2:4)
# 
# # horiz normal version #NICE
# par(mar = c(3,1,1,7))
# plot(dend, horiz  = TRUE, cex = 0.6, label.offset = 0.5)
# colored_bars(cbind(ct[,3:1], col_car_type), dend, rowLabels = c(paste0("k = ", 4:2), "Car Type"))
# 
# 
# #CUT TREE
# cutree(dend, k = 2:4)
# 
# 
# 
# 
# 
# 
# #Cluster Plot
# fviz_cluster(list(data = df, cluster = sub_grp)) 
# 
# fviz_cluster(list(data = df, cluster = sub_grp),
#              labelsize = 8) 
# 
# 



# #heatmap?
# data(sample_tcga)
# #transpose
# dataTable <- t(sample_tcga)
# #calculate the correlation based distance
# row_dist <- as.dist(1-cor(t(dataTable), method = "pearson"))
# col_dist <- as.dist(1-cor(dataTable, method = "pearson"))
# #hierarchical clustering
# col_hc <- hclust(col_dist, method = "complete")
# row_hc <- hclust(row_dist, method = "complete")
# 
# 
# #plot heatmap
# #HC Figure 1
# heatmap.plus(dataTable, Rowv=as.dendrogram(row_hc), Colv=as.dendrogram(col_hc),
#              labRow="", labCol="", margins = c(2,1), xlab = "HC", 
#              col=brewer.pal(11, "RdBu"))
# 
# 
# 
# 
# #heatmap?
# #use df data from above
# 
# #transpose
# dataTable <- t(df)
# #calculate the correlation based distance
# row_dist <- as.dist(1-cor(t(dataTable), method = "pearson"))
# col_dist <- as.dist(1-cor(dataTable, method = "pearson"))
# #hierarchical clustering
# col_hc <- hclust(col_dist, method = "complete")
# row_hc <- hclust(row_dist, method = "complete")
# 
# 
# #plot heatmap
# #HC Figure 1
# heatmap.plus(dataTable, Rowv=as.dendrogram(row_hc), Colv=as.dendrogram(col_hc),
#              labRow="", labCol="", margins = c(2,1), xlab = "HC", 
#              col=brewer.pal(11, "RdBu"))