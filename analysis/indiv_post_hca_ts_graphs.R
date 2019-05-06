
#Input Post Model DF List
models_list = list( df_post_cluster_m0,
                    df_post_cluster_m1,
                    df_post_cluster_m2,
                    df_post_cluster_m3,
                    df_post_cluster_m4
                 )

#Input Model Method Names
method_names = list("time_series_hca_ward_k3_polar_m0",
                    "time_series_hca_ward_k3_polar_m1",
                    "time_series_hca_ward_k3_polar_m2",
                    "time_series_hca_ward_k3_polar_m3",
                    "time_series_hca_ward_k3_polar_m4"
                   )

#Loop Over Models and Make Graphs
for(i in seq_along(models_list)){

    ## Make Graphs From Results
    model = models_list[[i]]
    method = method_names[[i]]
    base = TRUE
    oth = TRUE


    df_hca_all <- model
    df_hca_all_dem <- df_hca_all %>% filter(cluster_party == "DEM")
    df_hca_all_rep <- df_hca_all %>% filter(cluster_party == "REP")
    df_hca_all_oth <- df_hca_all %>% filter(cluster_party == "OTH")

    #Print Stats
    mean(df_hca_all$partisan_score, na.rm = TRUE)
    mean(df_hca_all_dem$partisan_score, na.rm = TRUE)
    mean(df_hca_all_rep$partisan_score, na.rm = TRUE)
    mean(df_hca_all_oth$partisan_score, na.rm = TRUE)

    source("indiv_mean_party_hca_loop.R")
    source("indiv_median_party_hca_loop.R")
    source("indiv_vartab_varplot_hca_loop.R")
    
}