####################################
## Load SOURCE
####################################

# source("indiv_source.R")
# source("indiv_vartab_varplot_functions.R")


#############################
## CID MASTER
#############################


# tab_title1 = "Partisan Polarization - All Firms, Unclassified - Party ID"
# tab_title2 = "Partisan Polarization - All Firms, Unclassified - Partisan Score"

# vt_all_cidmaster <- var_sum_table(df1_pid, 
#                                   "output/tables/indiv_var_all_cidmaster_pid_hca_dem.tex",
#                                   tab_title1)
# vt_cycle_cidmaster <- var_cycle_table(df1_ps, 
#                                       "output/tables/indiv_var_cycle_cidmaster_ps_hca_dem.tex", 
#                                       tab_title2)



plt_title1 = "Partisan Polarization (PID) - All Firms"
plt_title2 = "Partisan Polarization (PS) - All Firms"

make_polar_graph_base_pid(df_polarization, "polarization_pid", "polarization_pid_base", plt_title1)
make_polar_graph_base_pid(df_polarization, "polarization_ps", "polarization_ps_base", plt_title2)

make_var_graph_base_pid(df_polarization, "var_pid", "cid_master_pid_base", plt_title1)
make_var_graph_base_ps(df_polarization, "cid_master_ps_base", plt_title2)


#TODO edit graph code
make_polar_graph_base_pid(df_polarization, "var_ps", "var_ps_base", plt_title2)
