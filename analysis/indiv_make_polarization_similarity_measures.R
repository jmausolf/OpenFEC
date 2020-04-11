####################################
## Load SOURCE
####################################

source("indiv_source.R")
source("indiv_vartab_varplot_functions.R")


####################################
## Generate Polarization Measures
####################################

df_polar_pid <- make_var_df(df_analysis, "cid_master") %>% 
  ungroup() %>% 
  
  #Add 0/1 Scaled Polarization: PID
  mutate(x = polarization_raw_pid) %>% 
  mutate(polarization_pid = ((x-min(x, na.rm = TRUE))
                             /(max(x, na.rm = TRUE)-min(x, na.rm = TRUE)))) %>% 
  select(-x)
  

df_polar_ps <- make_var_df_partisan(df_analysis, "cid_master") %>% 
  ungroup() %>% 
  
  #Add 0/1 Scaled Polarization: PS
  mutate(x = polarization_raw_ps) %>% 
  mutate(polarization_ps = ((x-min(x, na.rm = TRUE))
                            /(max(x, na.rm = TRUE)-min(x, na.rm = TRUE)))) %>% 
  select(-x)


df_polarization <- full_join(df_polar_pid, df_polar_ps) 