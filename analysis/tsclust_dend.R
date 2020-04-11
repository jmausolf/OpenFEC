
# hca_model <- hc

make_partisan_plot_tsclust <- function(hca_model, gtitle="my graph title", gtyp="graph_spec", K=3){
  
  #Rejoin HCA Clusters to Original Data for Better Plots
  #df_filtered <- rejoin_clusters_data(df_filtered, hca_model)
  df_filtered <- cutree(as.hclust(hca_model), k = K, order_clusters_as_data = FALSE) %>% 
  #df_filtered <- stats::cutree(hca_model, k = 3) %>% 
    as.data.frame(.) %>%
    dplyr::rename(.,cluster = .) %>%
    tibble::rownames_to_column("cid_master")

  df_filtered <-
  
  
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

gtitle = paste("Hiearchical Cluster Model of Partisan Polarization", "1980", "-", "2018", "(Time Series AGNES HCA Using Ward)", sep = " ")
gfile = paste("1980", "2018", sep = "_")
make_partisan_plot_tsclust(hc, gtitle, gfile)
