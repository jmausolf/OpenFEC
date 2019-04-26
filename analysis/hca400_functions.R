####################################
## Load Contrib SOURCE
####################################

#source("indiv_source.R")

## Load Additional Libraries
library(cluster)   
library(factoextra)
library(dendextend)
library(circlize)
library(dendsort)
library(heatmap.plus)
library(RColorBrewer)
library(forcats)
library(reshape2)
library(zoo)

options(scipen=999)



########################################
## Functions
########################################


spread_chr <- function(data, key_col, value_cols, fill = NA, 
                       convert = FALSE,drop = TRUE,sep = NULL){
  n_val <- length(value_cols)
  result <- vector(mode = "list", length = n_val)
  id_cols <- setdiff(names(data), c(key_col,value_cols))
  
  for (i in seq_along(result)){
    result[[i]] <- spread(data = data[,c(id_cols,key_col,value_cols[i]),drop = FALSE],
                          key = !!key_col,
                          value = !!value_cols[i],
                          fill = fill,
                          convert = convert,
                          drop = drop,
                          sep = paste0(sep,value_cols[i],sep))
  }
  
  result %>%
    purrr::reduce(.f = full_join, by = id_cols)
}


post_cluster_df <- function(df, df_hca, hca_model, cycle_min = 1980, cycle_max = 2020){
  #Inspect Clusters
  dfclust <- rejoin_clusters_data(df_hca, hca_model) %>% 
    select(cid_master, cluster) 
  

  df_simple <- df %>%
    filter(cycle >= cycle_min & cycle <= cycle_max ) %>% 
    
    #Group by Company (Collapse Across Cycles)
    group_by(cid_master) %>%
    
    #Features
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
  #print(df_simple)
  #Join
  df_post_cluster <- full_join(dfclust, df_simple) %>% 
    mutate(cycle_min = cycle_min,
           cycle_max = cycle_max,
           cycle_mean = mean(c(cycle_min, cycle_max))
    )
  
  return(df_post_cluster)
  
}



prepare_hca_df <- function(input_df, cycle_min = 1980, cycle_max = 2020){
  
  
  # df_filtered <- input_df %>% 
  #   filter(cycle >= cycle_min & cycle <= cycle_max ) %>% 
  #   
  #   #Group by Company (Collapse Across Cycles)
  #   group_by(cid_master) %>%
  #   
  #   #Features
  #   summarize(mean_partisan_score = mean(partisan_score, na.rm = TRUE),
  #               median_partisan_score = median(partisan_score, na.rm = TRUE))
  
  df_filtered <- input_df %>% 
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
                 sep = "_") 
    
    #Spread Year Columns
    df_filtered <- df_filtered %>% 
      spread_chr(key_col = "cycle",
                 value_cols = tail(names(df_filtered), -2),
                 sep = "_") 
    
    
    #Convert to Format Needed for HCA (and Graphs)
    df <- as.data.frame(df_filtered)
    
    #Add company names as rownames
    rownames(df) <- df$cid_master
    df$cid_master <- NULL
    
    #Prep and Standardize Data
    
    #M
    df <- na.aggregate(df)
    df <- Filter(function(x)!all(is.na(x)), df)
    df <- na.omit(df)
    
    #Prep and Standardize Data
    df <- scale(df)
  
  out_dfs <- list(df_filtered, df)
  return(out_dfs)
}



rejoin_clusters_data <- function(df_filtered,
                                 hca_model, 
                                 K=3 
                                 #shapesvec=c("15", "0", "1", "19", "4"),
                                 #colorsvec=c("#BF1200", "#BF1200", "#2129B0", "#2129B0", "#77777")
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
  df_filtered$cluster <-  sub_grp_sorted
  
  return(df_filtered)
}




make_partisan_plot <- function(hca_model, df_filtered, gtitle="my graph title", gtyp="graph_spec"){
  
  #Rejoin HCA Clusters to Original Data for Better Plots
  df_filtered <- rejoin_clusters_data(df_filtered, hca_model)

  dfclust <- df_filtered %>%
    #mutate(cluster = sub_grp_sorted) %>% 
    arrange(cluster) %>% 
    #Set shapes
    mutate(shapes = as.numeric(as.character(fct_recode(as.factor(cluster),
                                                       "15" = "1",
                                                       "4" = "2",
                                                       "19" = "3"
                                                       #"19" = "4",
                                                       #"4" = "5"
    )))) %>% 
    #Set colors
    mutate(colors = as.character(fct_recode(as.factor(cluster),
                                            "#BF1200" = "1",
                                            "#3A084A" = "2",
                                            "#2129B0" = "3"
                                            #"#2129B0" = "4",
                                            #"#777777" = "5"
    ))) %>%
    #Set marker size
    mutate(msize = as.numeric(as.character(fct_recode(as.factor(cluster),
                                          "0.15" = "1",
                                          "0.15" = "2", 
                                          "0.15" = "3"))))
  
  #Shape and Color Vectors
  shapevec <- dfclust$shapes
  markervec <- dfclust$msize
  colorvec <- dfclust$colors
  
  
  #Specify Graph Options
  dend <- as.dendrogram(hca_model) %>% 
    color_branches(k = 3, col=c("#BF1200", "#3A084A", "#2129B0")) %>% 
    color_labels(k = 3, col=c("#BF1200", "#3A084A", "#2129B0")) %>% 
    assign_values_to_leaves_nodePar(value=shapevec, "pch") %>% 
    assign_values_to_leaves_nodePar(value=markervec, "cex") %>% 
    assign_values_to_leaves_nodePar(value=colorvec, "col") 
  
  
  
  #Specs
  ppi <- 1000
  fp <- "output/plots/"
  modnm <- deparse(substitute(hca_model))
  
  
  #Horiz Graph
  hz <- function(gtitle){
    par(mfrow = c(1,1))
    par(mar=c(3,4,1,6)) # set margins
    par(cex.axis=1)
    labels_cex(dend) <- 0.15 #label size
    plot(dendsort(dend, type="average", isReverse=FALSE), horiz  = TRUE, cex = 0.5)
    legend("bottomleft", 
           legend = c("Polorized Democrat" , "Amphibious Partisans" , "Polorized Republican"), 
           col = c("#2129B0", "#3A084A", "#BF1200"), 
           pch = c(19,4,15), bty = "n",  pt.cex = 2, cex = 1, 
           text.col = "black", horiz = FALSE, inset = c(0.0, 0.0))
    title(main = gtitle)      
  }
  
  png(paste0(fp,modnm,"_",gtyp,"_horiz_plot.png"), width=11.5*ppi, height=8*ppi, res=ppi)
  hz(gtitle)
  dev.off()
  
  pdf(paste0(fp,modnm,"_",gtyp,"_horiz_plot.pdf"), width=11.5, height=8)
  hz(gtitle)
  dev.off()
  
}







make_partisan_plot_2004_2018 <- function(hca_model, df_filtered, gtitle="my graph title", gtyp="graph_spec"){
  
  #Rejoin HCA Clusters to Original Data for Better Plots
  df_filtered <- rejoin_clusters_data(df_filtered, hca_model)

  dfclust <- df_filtered %>%
    #mutate(cluster = sub_grp_sorted) %>% 
    arrange(cluster) %>% 
    #Set Shapes
    mutate(shapes = as.numeric(as.character(fct_recode(as.factor(cluster),
                                                       "15" = "2",
                                                       "4" = "1",
                                                       "19" = "3"
                                                       #"19" = "4",
                                                       #"4" = "5"
    )))) %>% 
    #Set Colors
    mutate(colors = as.character(fct_recode(as.factor(cluster),
                                            "#BF1200" = "2",
                                            "#3A084A" = "1",
                                            "#2129B0" = "3"
                                            #"#2129B0" = "4",
                                            #"#777777" = "5"
    ))) %>%
    #Set marker size
    mutate(msize = as.numeric(as.character(fct_recode(as.factor(cluster),
                                                      "0.15" = "1",
                                                      "0.15" = "2", 
                                                      "0.15" = "3"))))
  
  #Shape and Color Vectors
  shapevec <- dfclust$shapes
  markervec <- dfclust$msize
  colorvec <- dfclust$colors
  
  
  #Specify Graph Options
  dend <- as.dendrogram(hca_model) %>% 
    color_branches(k = 3, col=c("#3A084A", "#BF1200", "#2129B0")) %>% 
    color_labels(k = 3, col=c("#3A084A", "#BF1200", "#2129B0")) %>% 
    assign_values_to_leaves_nodePar(value=shapevec, "pch") %>% 
    assign_values_to_leaves_nodePar(value=markervec, "cex") %>% 
    assign_values_to_leaves_nodePar(value=colorvec, "col") 
  
  
  
  #Specs
  ppi <- 1000
  fp <- "output/plots/"
  modnm <- deparse(substitute(hca_model))
  
  
  #Horiz Graph
  hz <- function(gtitle){
    par(mfrow = c(1,1))
    par(mar=c(3,4,1,6)) # set margins
    par(cex.axis=1)
    labels_cex(dend) <- 0.15 #label size
    plot(dendsort(dend, type="average", isReverse=FALSE), horiz  = TRUE, cex = 0.5)
    #plot(dend, horiz  = TRUE, cex = 0.5)
    legend("bottomleft", 
           legend = c("Polorized Democrat" , "Amphibious Partisans" , "Polorized Republican"), 
           col = c("#2129B0", "#3A084A", "#BF1200"), 
           pch = c(19,4,15), bty = "n",  pt.cex = 2, cex = 1, 
           text.col = "black", horiz = FALSE, inset = c(0.0, 0.0))
    title(main = gtitle)      
  }
  
  png(paste0(fp,modnm,"_",gtyp,"_horiz_plot.png"), width=11.5*ppi, height=8*ppi, res=ppi)
  hz(gtitle)
  dev.off()
  
  pdf(paste0(fp,modnm,"_",gtyp,"_horiz_plot.pdf"), width=11.5, height=8)
  hz(gtitle)
  dev.off()
  

}









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
# plot(dendsort(as.dendrogram(hc3), type="min", isReverse=TRUE), cex = 0.6)
# 
# 









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