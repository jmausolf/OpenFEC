##Load Data Source and Core Functions
source("indiv_vartab_varplot_functions.R")
source("indiv_partisan_functions.R")


partisan_filter <- function(model_post_df) {
  
  df_hca_all <- model_post_df
  
  df_hca_filter <- model_post_df %>% 
    filter(cycle >= 2008) %>% 
    group_by(cid_master) %>% 
    mutate(pid2 = as.numeric(pid2)) %>% 
    select(cid_master, pid2, partisan_score, polarization_raw_pid, polarization_raw_ps) %>% 
    summarise_all(list(~mean(.)), na.rm = TRUE) %>% 
    mutate_if(is.numeric, list(~percent_rank(.), ~sum(.))) %>%
    select(cid_master, ends_with("_rank"))
  
  
  
  df_hca_all <- left_join(model_post_df, df_hca_filter, by = "cid_master")
  
  
  
  df_hca_all_dem <- df_hca_all %>% 
    filter(cluster_party == "DEM") %>% 
    filter(pid2_percent_rank <= 0.26 | partisan_score_percent_rank <= 0.26) 
  
  
  df_hca_all_rep <- df_hca_all %>% filter(cluster_party == "REP") %>% 
    filter(pid2_percent_rank >= 0.74 | partisan_score_percent_rank >= 0.74) 

  
  # df_hca_all_oth <- df_hca_all %>% filter(cluster_party == "OTH") %>% 
  #   filter(pid2_percent_rank < 0.74 | partisan_score_percent_rank < 0.74) %>% 
  #   filter(pid2_percent_rank > 0.26 | partisan_score_percent_rank > 0.26)

  df_hca_all_oth <- df_hca_all %>% filter(cluster_party == "OTH") 
  
  
  df_include <- bind_rows(df_hca_all_dem, df_hca_all_oth, df_hca_all_rep) %>% 
    group_by(cid_master) %>% 
    select(cid_master) %>% 
    distinct()
  
  
  df_exclude <- anti_join(df_hca_filter, df_include)
  
  output_lists <- list(all=df_hca_all,
                       dems=df_hca_all_dem,
                       rep=df_hca_all_rep,
                       oth=df_hca_all_oth,
                       filtered=df_hca_filter,
                       include=df_include,
                       exclude=df_exclude)
  

  return(output_lists)
  
}


#Input Post Model DF List
models_list = list( df_post_cluster_m0,
                    df_post_cluster_m1
                    #df_post_cluster_m2,
                    #df_post_cluster_m3,
                    #df_post_cluster_m4
                 )

#Input Model Method Names
method_names = list("time_series_hca_ward_k3_polar_filtered_m0",
                    "time_series_hca_ward_k3_polar_filtered_m1"
                    #"time_series_hca_ward_k3_polar_filtered_m2",
                    #"time_series_hca_ward_k3_polar_filtered_m3",
                    #"time_series_hca_ward_k3_polar_filtered_m4"
                   )

#Loop Over Models and Make Graphs
for(i in seq_along(models_list)){

    ## Make Graphs From Results
    model = models_list[[i]]
    method = method_names[[i]]
    mname <- tail(strsplit(method, "_")[[1]], n=1)
    base = TRUE
    oth = TRUE


    df_partisan <- partisan_filter(model)
    assign(paste("df_partisan", mname, sep="_"),df_partisan)
    df_hca_all <- df_partisan$all
    df_hca_all_dem <- df_partisan$dem
    df_hca_all_rep <- df_partisan$rep
    df_hca_all_oth <- df_partisan$oth

    #Print Stats
    mean(df_hca_all$partisan_score, na.rm = TRUE)
    mean(df_hca_all_dem$partisan_score, na.rm = TRUE)
    mean(df_hca_all_rep$partisan_score, na.rm = TRUE)
    mean(df_hca_all_oth$partisan_score, na.rm = TRUE)

    source("indiv_mean_party_hca_loop.R")
    source("indiv_median_party_hca_loop.R")
    source("indiv_vartab_varplot_hca_loop.R")
    
}