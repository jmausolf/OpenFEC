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




#so basically it sorts it into "polarized REP firms, somewhat REP firms POL DEM firms, somewhat DEM firms
#overall, all years

#redo s.t.
#idk 1980-1999
# 2000-2008
# 2009-2018

#examine growth of polarized clusters?




########################################
## Data Preparation
########################################

##Individual Level Data
df_org <- dfocc3 %>% 
  #group_by(cid_master, cycle) %>% 
  group_by(cid_master) %>% 
  summarize(mean_partisan_score = mean(partisan_score, na.rm = TRUE),
            median_partisan_score = median(partisan_score, na.rm = TRUE))
# ,
#             min_partisan_score = min(partisan_score))
  # summarize(mean_partisan_score = mean(partisan_score, na.rm = TRUE)) %>% 
  # spread(key = cycle, value = mean_partisan_score)
  #reshape(df, idvar = "cid_master", timevar = "cycle", direction = "wide") %>% 
  
df <- as.data.frame(df_org)

#Add company names as rownames
rownames(df) <- df$cid_master
df$cid_master <- NULL
print(df)


#Prep and Standardize Data
df <- na.omit(df)
df <- scale(df)

# Dissimilarity matrix
d <- dist(df, method = "euclidean")


#Basic Model
hc3 <- agnes(df, method = "ward")


# Cut tree into 4 groups 
sub_grp <- cutree(as.hclust(hc3), k = 4, order_clusters_as_data = FALSE)

#Sort Properly (For Post Vectors)
sub_grp_df <- as.data.frame(sub_grp)
sub_grp_df$cid_master <- rownames(sub_grp_df)
sub_grp_df <- sub_grp_df %>% arrange(cid_master)
sub_grp_sorted <- sub_grp_df$sub_grp

#See what groups original data is in
dfclust <- df_org %>%
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



#Shape and Color Vectors
shapevec <- dfclust$shapes
colorvec <- dfclust$colors

#Specify Graph Options
dend <- as.dendrogram(hc3) %>% 
  color_branches(k = 4, col=c("#BF1200", "#BF1200", "#2129B0", "#2129B0")) %>% 
  color_labels(k = 4, col=c("#BF1200", "#BF1200", "#2129B0", "#2129B0")) %>% 
  assign_values_to_leaves_nodePar(value=shapevec, "pch") %>% 
  assign_values_to_leaves_nodePar(value=colorvec, "col") 

par(mfrow = c(1,1))
labels_cex(dend) <- 0.5
plot(dend, horiz  = TRUE, cex = 0.6)
legend("bottomleft", 
       legend = c("Polorized Democrat" , "Lean Democrat" , "Lean Republican" , "Polorized Republican"), 
       col = c("#2129B0", "#2129B0", "#BF1200", "#BF1200"), 
       pch = c(19,1,0,15), bty = "n",  pt.cex = 1.5, cex = 0.6 , 
       text.col = "black", horiz = FALSE, inset = c(0.0, 0.0))
title(main = "HC3 Agnes Dendogram of Partisan Polarization",
      sub = "A subtitle")




#Verticle Dend
labels_cex(dend) <- 0
plot(dend, cex = 0.6, leaflab = "none")
legend("topleft", 
       legend = c("Polorized Democrat" , "Lean Democrat" , "Lean Republican" , "Polorized Republican"), 
       col = c("#2129B0", "#2129B0", "#BF1200", "#BF1200"), 
       pch = c(19,1,0,15), bty = "n",  pt.cex = 1.5, cex = 0.6 , 
       text.col = "black", horiz = FALSE, inset = c(0.0, 0.0))



#Combined
# png("hc3_combined.png", width = 1400, height = 1000)
par(mfrow = c(1,2))

#Verticle Dend
plot(dend, cex = 0.6, leaflab = "none")
legend("topleft", 
       legend = c("Polorized Democrat" , "Lean Democrat" , "Lean Republican" , "Polorized Republican"), 
       col = c("#2129B0", "#2129B0", "#BF1200", "#BF1200"), 
       pch = c(19,1,0,15), bty = "n",  pt.cex = 1.5, cex = 0.6 , 
       text.col = "black", horiz = FALSE, inset = c(0.0, 0.0))
#Horz
labels_cex(dend) <- 0.5
plot(dend, horiz  = TRUE, cex = 0.6)
legend("bottomleft", 
       legend = c("Polorized Democrat" , "Lean Democrat" , "Lean Republican" , "Polorized Republican"), 
       col = c("#2129B0", "#2129B0", "#BF1200", "#BF1200"), 
       pch = c(19,1,0,15), bty = "n",  pt.cex = 1.5, cex = 0.6 , 
       text.col = "black", horiz = FALSE, inset = c(0.0, 0.0))
title(main = "HC3 Agnes Dendogram of Partisan Polarization",
      sub = "A subtitle")
# dev.off()



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