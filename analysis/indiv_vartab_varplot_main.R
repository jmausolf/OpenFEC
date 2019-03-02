####################################
## Load SOURCE
####################################

source("indiv_source.R")
source("indiv_vartab_varplot_functions.R")


#############################
## CID MASTER
#############################

df1_pid <- make_var_df(df_analysis, "cid_master")
df1_ps <- make_var_df_partisan(df_analysis, "cid_master")

plt_title1 = "Partisan Polarization (PID) - All Firms"
plt_title2 = "Partisan Polarization (PS) - All Firms"
tab_title1 = "Partisan Polarization - All Firms, Unclassified - Party ID"
tab_title2 = "Partisan Polarization - All Firms, Unclassified - Partisan Score"

vt_all_cidmaster <- var_sum_table(df1_pid, 
                                  "output/tables/indiv_var_all_cidmaster_pid_hca_dem.tex",
                                  tab_title1)
vt_cycle_cidmaster <- var_cycle_table(df1_ps, 
                                      "output/tables/indiv_var_cycle_cidmaster_ps_hca_dem.tex", 
                                      tab_title2)



gr_cid_master_pid <- make_var_graph_base_pid(df1_pid, "cid_master_pid_base", plt_title1)
gr_cid_master_ps <- make_var_graph_base_ps(df1_ps, "cid_master_ps_base", plt_title2)



