####################################
## Load Contrib SOURCE
####################################

source("indiv_vartab_varplot_functions.R")



# Make Polarization Subframes from Model Frame

df_polar_dem <- model %>% 
  select(cid_master, cluster_party, cycle) %>% 
  distinct() %>% 
  filter(cluster_party == "DEM") %>% 
  inner_join(df_polarization)


df_polar_rep <- model %>% 
  select(cid_master, cluster_party, cycle) %>% 
  distinct() %>% 
  filter(cluster_party == "REP") %>% 
  inner_join(df_polarization)


df_polar_oth <- model %>% 
  select(cid_master, cluster_party, cycle) %>% 
  distinct() %>% 
  filter(cluster_party == "OTH") %>% 
  inner_join(df_polarization)



# Make Partisan ID Polarization Graphs

plt_title1 = "Partisan Polarization Democratic Firms (PID)"
#make_polar_graph_base_pid(df_polar_dem, "polarization_pid", "polarization_pid_dem", plt_title1)
make_polar_graph(df_polar_dem, key = "polarization_pid", plt_type = "dem",  
                 file_label = paste("polarization_pid_dem", method, sep='_'), plt_title = plt_title1)


plt_title1 = "Partisan Polarization Republican Firms (PID)"
make_polar_graph(df_polar_rep, key = "polarization_pid", plt_type = "rep",  
                          file_label = paste("polarization_pid_rep", method, sep='_'), plt_title = plt_title1)


plt_title1 = "Partisan Polarization Amphibious Firms (PID)"
make_polar_graph(df_polar_oth, key = "polarization_pid", plt_type = "oth",  
                 file_label = paste("polarization_pid_oth", method, sep='_'), plt_title = plt_title1)



# Make Partisan Score Polarization Graphs

plt_title2 = "Partisan Polarization Democratic Firms (PS)"
#make_polar_graph_base_pid(df_polar_dem, "polarization_pid", "polarization_pid_dem", plt_title1)
make_polar_graph(df_polar_dem, key = "polarization_ps", plt_type = "dem",  
                 file_label = paste("polarization_ps_dem", method, sep='_'), plt_title = plt_title2)


plt_title2 = "Partisan Polarization Republican Firms (PS)"
make_polar_graph(df_polar_rep, key = "polarization_ps", plt_type = "rep",  
                 file_label = paste("polarization_ps_rep", method, sep='_'), plt_title = plt_title2)


plt_title2 = "Partisan Polarization Amphibious Firms (PS)"
make_polar_graph(df_polar_oth, key = "polarization_ps", plt_type = "oth",  
                 file_label = paste("polarization_ps_oth", method, sep='_'), plt_title = plt_title2)