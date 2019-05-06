

base_features0 <- function(input_df, cycle_min = 1980, cycle_max = 2020){
  
  df_filtered <- input_df %>% 
    filter(cycle >= cycle_min & cycle <= cycle_max) %>%  
    filter(!is.na(pid2),
           !is.na(partisan_score),
           !is.na(occ3),
           !is.na(occlevels)) %>% 
    #Group by Company (Collapse Across Cycles)
    group_by(cycle, cid_master, occ3) %>% 
    summarize(mean_pid2 = mean(as.numeric(pid2), na.rm = TRUE),
              median_pid2 = median(as.numeric(pid2), na.rm = TRUE),
              mean_ps = mean(partisan_score, na.rm = TRUE),
              median_ps = median(partisan_score, na.rm = TRUE),
              mean_ps_mode = mean(as.numeric(partisan_score_mode), na.rm = TRUE), 
              mean_ps_min = mean(as.numeric(partisan_score_min), na.rm = TRUE),
              mean_ps_max = mean(as.numeric(partisan_score_max), na.rm = TRUE)
    )
  
  return(df_filtered)
  
}



base_features1 <- function(input_df, cycle_min = 1980, cycle_max = 2020){
  
  df_filtered <- input_df %>% 
    filter(cycle >= cycle_min & cycle <= cycle_max) %>%  
    filter(!is.na(pid2),
           !is.na(partisan_score),
           !is.na(occ3),
           !is.na(occlevels)) %>% 
    #Group by Company (Collapse Across Cycles)
    group_by(cycle, cid_master, occ3) %>% 
    summarize(mean_pid2 = mean(as.numeric(pid2), na.rm = TRUE),
              mean_pid3 = mean(as.numeric(pid3), na.rm = TRUE),
              median_pid2 = median(as.numeric(pid2), na.rm = TRUE),
              median_pid3 = median(as.numeric(pid3), na.rm = TRUE),
              mean_ps = mean(partisan_score, na.rm = TRUE),
              median_ps = median(partisan_score, na.rm = TRUE),
              mean_ps_mode = mean(as.numeric(partisan_score_mode), na.rm = TRUE), 
              mean_ps_min = mean(as.numeric(partisan_score_min), na.rm = TRUE),
              mean_ps_max = mean(as.numeric(partisan_score_max), na.rm = TRUE),
              sum_pid_count = sum(as.numeric(party_id_count))      
    )
  
  return(df_filtered)
  
}


base_features2 <- function(input_df, cycle_min = 1980, cycle_max = 2020){
  
  df_filtered <- input_df %>% 
    filter(cycle >= cycle_min & cycle <= cycle_max) %>%  
    filter(!is.na(pid2),
           !is.na(partisan_score),
           !is.na(occ3),
           !is.na(occlevels)) %>% 
    #Group by Company (Collapse Across Cycles)
    group_by(cycle, cid_master, occ3) %>% 
    summarize(mean_pid2 = mean(as.numeric(pid2), na.rm = TRUE),
              median_pid2 = median(as.numeric(pid2), na.rm = TRUE),
              mean_ps = mean(partisan_score, na.rm = TRUE),
              median_ps = median(partisan_score, na.rm = TRUE)
    )
  
  return(df_filtered)
  
}


base_features3 <- function(input_df, cycle_min = 1980, cycle_max = 2020){
  
  df_filtered <- input_df %>% 
    filter(cycle >= cycle_min & cycle <= cycle_max) %>%  
    filter(!is.na(pid2),
           !is.na(partisan_score),
           !is.na(occ3),
           !is.na(occlevels)) %>% 
    #Group by Company (Collapse Across Cycles)
    group_by(cycle, cid_master, occ3) %>% 
    summarize(mean_pid2 = mean(as.numeric(pid2), na.rm = TRUE),
              #median_pid2 = median(as.numeric(pid2), na.rm = TRUE),
              mean_ps = mean(partisan_score, na.rm = TRUE),
              #median_ps = median(partisan_score, na.rm = TRUE)
    )
  
  return(df_filtered)
  
}

