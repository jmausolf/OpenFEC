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

infer_partisanship <- function(df) {
  
  cluster_party_key <- df %>% 
    group_by(cluster) %>%
    summarize(mean_pid2_med = mean(median_pid2, na.rm = TRUE),
              mean_ps_med = mean(median_ps, na.rm = TRUE)
    ) %>% 
    mutate(cluster_party = "OTH") %>% 
    mutate(cluster_party = ifelse(    mean_pid2_med == max(mean_pid2_med) &
                                        mean_ps_med == max(mean_ps_med), 
                                      "REP", cluster_party )) %>% 
    mutate(cluster_party = ifelse(    mean_pid2_med == min(mean_pid2_med) &
                                        mean_ps_med == min(mean_ps_med), 
                                      "DEM", cluster_party )) %>% 
    select(cluster, cluster_party)
  
  df_out <- left_join(df, cluster_party_key, by = 'cluster') 
  return(df_out)
  
}

dend_color_order <- function(party_order, ...){
  other_args <- rlang::list2(...)
  
  # "#BF1200" = "REP",
  # "#3A084A" = "OTH",
  # "#2129B0" = "DEM"
  
  order1 = c("REP", "OTH", "DEM")
  order2 = c("REP", "DEM", "OTH")
  order3 = c("OTH", "DEM", "REP")
  order4 = c("OTH", "REP", "DEM")
  order5 = c("DEM", "REP", "OTH")
  order6 = c("DEM", "OTH", "REP")
  
  if(identical(party_order, order1)){
    print(order1)
    return(c("#BF1200", "#3A084A", "#2129B0"))
  }
  
  if(identical(party_order, order2)){
    print(order2)
    return(c("#BF1200", "#2129B0", "#3A084A"))
  }
  
  if(identical(party_order, order3)){
    print(order3)
    return(c("#3A084A", "#2129B0", "#BF1200"))
  }

  if(identical(party_order, order4)){
    print(order4)
    return(c("#3A084A", "#BF1200", "#2129B0"))
  } 
  
  if(identical(party_order, order5)){
    print(order5)
    return(c("#2129B0", "#BF1200", "#3A084A"))
  } 
  
  if(identical(party_order, order6)){
    print(order6)
    return(c("#2129B0", "#3A084A", "#BF1200"))
    
  } 

}


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


#TODO, INPUT THE COMBINED GRAPH INTO THIS
post_cluster_df_k <- function(df, df_hca, hca_model, cycle_min = 1980, cycle_max = 2020, K=3){
  
  #Inspect Clusters
  dfclust <- cutree(as.hclust(hca_model), k = K, order_clusters_as_data = FALSE) %>% 
    as.data.frame(.) %>%
    dplyr::rename(.,cluster = .) %>%
    tibble::rownames_to_column("cid_master")


  df_simple <- df %>%
    filter(cycle >= cycle_min & cycle <= cycle_max ) %>% 
    
    #Group by Company (Collapse Across Cycles)
    group_by(cid_master) %>%
    
    #Features (For Infering Partisanship)
    summarize(mean_pid2 = mean(as.numeric(pid2), na.rm = TRUE),
              median_pid2 = median(as.numeric(pid2), na.rm = TRUE),
              mean_ps = mean(partisan_score, na.rm = TRUE),
              median_ps = median(partisan_score, na.rm = TRUE)
    )

  # #Join
  df_post_cluster <- full_join(dfclust, df_simple) %>% 
    mutate(cycle_min = cycle_min,
           cycle_max = cycle_max,
           cycle_mean = mean(c(cycle_min, cycle_max))
    )
  
  return(df_post_cluster)
  
}


prepare_hca_ts_df <- function(base_features_df, additional_feature_df, cycle_min = 1980, cycle_max = 2020){
  
    #Base Features
    df_filtered <- base_features_df %>% 
      filter(cycle >= cycle_min & cycle <= cycle_max)

    #Filter Additional Features for Given Years
    df_polarization_prep <- additional_feature_df %>% 
      filter(cycle >= cycle_min & cycle <= cycle_max)

    #Join Prepped Input DF and Additional Features DF
    df_pre_hca_out <- left_join(df_filtered, df_polarization_prep)
    print(dim(df_pre_hca_out))
    
    #Spread OCC Columns
    df_pre_hca <- df_pre_hca_out %>% 
      spread_chr(key_col = "occ3",
                value_cols = tail(names(df_pre_hca_out), -3),
                sep = "_") %>% 
      arrange(cycle)

    #########################################################
    ## Scaling and Removing/Filling NA for TS Matrix
    ## Distance Function
    #########################################################

    #Extract CID MASTER (for labels)
    df_cid_master <- df_pre_hca %>% 
      ungroup() %>% 
      select(cid_master) %>% 
      arrange(cid_master)

    #Prep and Standardize Data
    df <- df_pre_hca %>% 
      arrange(cid_master, cycle) %>% 
      ungroup() %>% 
      select(-cid_master, cycle) 

    #Scale Without Centering (Centering Increases NA Values)
    df <- scale(df, center = FALSE)

    #Backward and Forward Fill NA's by Row (I.E. from Adjacent Columns)
    #i.e. use Manager/Other etc to fill missing exec / manager
    #or   use CSUTIE/Manager/Other etc to fill missing Manager/Other
    #in this way, na fill uses relevant values from that firm-year instead of the whole dataset

    #Backfill NA from Next Column
    dfT <- t(df)
    dfT <- na.locf(dfT, fromLast = TRUE)
    df <- as.data.frame(t(dfT))

    #Fowardfill Any Remaining NA from Next Column
    dfT2 <- t(df)
    dfT2 <- na.locf(dfT2, fromLast = FALSE)
    df <- as.data.frame(t(dfT2))
    df <- na.omit(df)
    
    #Rebind Labels to Cleaned DF
    df <- bind_cols(df_cid_master, df)

    #Split Into A Series of TS Tibbles for Each Company
    df_ts_matrix <- split(df, df$cid_master)

    #NA Remove and Clean All TS Tibbles, Convert to Matrices
    matrix_list <-  list()
    for(i in seq_along(df_ts_matrix)){
      
      df <- as.data.frame(df_ts_matrix[[i]])
      df <- as.data.frame(df) %>% 
        ungroup() %>% 
        select(-cid_master, -cycle) 

      df <- Filter(function(x)!all(is.na(x)), df)
      df <- na.omit(df)
      matrix_list[[i]] <- data.matrix(df)
    }

    #Add Labels to Completed Matrix
    df_get_names <- df_filtered %>% 
      ungroup() %>% 
      select(cid_master) %>% 
      distinct() %>% 
      arrange(cid_master)

    names(matrix_list) <- as.list(df_get_names)[[1]]


  outlist <- list("matrix_list"=matrix_list, "prep_df"=df_pre_hca_out)
  return(outlist)

}



make_partisan_plot_tsclust <- function(hca_model, prep_df, y1, y2, K=3, 
                                       gtitle="my graph title", gtyp="graph_spec",
                                       party_viz="NONE"){
  if(identical(party_viz, "NONE")){
    party_color_vec <- c("#3A084A", "#2129B0", "#BF1200")
  } else {
    party_color_vec <- dend_color_order(party_viz)
  }

  print(party_color_vec)

  #Rejoin HCA Clusters to Original Data for Better Plots
  #df_filtered <- rejoin_clusters_data(df_filtered, hca_model)
  # df_filtered <- cutree(as.hclust(hca_model), k = 3, order_clusters_as_data = FALSE) %>% 
  # #df_filtered <- stats::cutree(hca_model, k = 3) %>% 
  #   as.data.frame(.) %>%
  #   dplyr::rename(.,cluster = .) %>%
  #   tibble::rownames_to_column("cid_master")
  
  df_labels <- cutree(as.hclust(hca_model), k = K, order_clusters_as_data = FALSE) %>% 
    #df_filtered <- stats::cutree(hca_model, k = 3) %>% 
    as.data.frame(.) %>%
    dplyr::rename(.,cluster = .) %>%
    tibble::rownames_to_column("cid_master")

  df_post <- post_cluster_df_k(df_analysis, df_labels, hca_model, y1, y2, K=3)

  df_filtered <- infer_partisanship(df_post) %>% 
    select(cid_master, cluster, cluster_party)
  
  dfclust <- df_filtered %>%
    #mutate(cluster = sub_grp_sorted) %>% 
    arrange(cluster) %>% 
    #Set shapes
    mutate(shapes = as.numeric(as.character(fct_recode(as.factor(cluster_party),
                                                       "15" = "REP",
                                                       "4" = "OTH",
                                                       "19" = "DEM"
                                                       #"19" = "4",
                                                       #"4" = "5"
    )))) %>% 
    #Set colors
    mutate(colors = as.character(fct_recode(as.factor(cluster_party),
                                            "#BF1200" = "REP",
                                            "#3A084A" = "OTH",
                                            "#2129B0" = "DEM"
                                            #"#2129B0" = "4",
                                            #"#777777" = "5"
    ))) %>%
    #Set marker size
    mutate(msize = as.numeric(as.character(fct_recode(as.factor(cluster_party),
                                                      "0.15" = "REP",
                                                      "0.15" = "OTH", 
                                                      "0.15" = "DEM"))))
  
  #Shape and Color Vectors
  shapevec <- dfclust$shapes
  markervec <- dfclust$msize
  colorvec <- dfclust$colors
  
  
  #Specify Graph Options
  dend <- as.dendrogram(hca_model) %>% 
    color_branches(k = 3, col=party_color_vec) %>% 
    color_labels(k = 3, col=party_color_vec) %>% 
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

  #Make File for Analysis
  df_post_cluster <- full_join(prep_df, df_filtered) 
  df_post_cluster <- full_join(df_analysis, df_post_cluster)
  
  return(df_post_cluster)

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