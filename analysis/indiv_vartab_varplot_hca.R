####################################
## Load Contrib SOURCE
####################################

source("indiv_source.R")
source("indiv_vartab_varplot_functions.R")

colors_neutral = rev(brewer.pal(n = 8, name = "Purples")[5:8])
colors_dem = rev(brewer.pal(n = 8, name = "Blues")[5:8])
colors_rep = rev(brewer.pal(n = 8, name = "Reds")[5:8])


#############################
## CID MASTER - POST HCA
#############################



##---------------------------- 
## Democratic Firm Graphs

df1_pid_dem <- make_var_df(dfocc3_hca_dem, "cid_master")
df1_ps_dem <- make_var_df_partisan(dfocc3_hca_dem, "cid_master")


plt_title = "Partisan Polarization - AGNES Polarized Democratic Firms"
tab_title1 = "Partisan Polarization - AGNES Polarized Democratic Firms - Party ID"
tab_title2 = "Partisan Polarization - AGNES Polarized Democratic Firms - Partisan Score"

vt_all_cidmaster <- var_sum_table(df1_pid_dem, 
                                  "output/tables/indiv_var_all_cidmaster_pid_hca_dem.tex",
                                  tab_title1)
vt_cycle_cidmaster <- var_cycle_table(df1_ps_dem, 
                                      "output/tables/indiv_var_cycle_cidmaster_ps_hca_dem.tex", 
                                      tab_title2)



gr_cid_master_pid <- make_var_graph_dem_pid(df1_pid_dem, "cid_master_pid_hca_dem", "Note: Party ID Used to Calculate Partisan Polarization", plt_title)
gr_cid_master_ps <- make_var_graph_dem_ps(df1_ps_dem, "cid_master_ps_hca_dem", "Note: Partisan Score Used to Calculate Partisan Polarization", plt_title)




##---------------------------- 
## Republican Firm Graphs

df1_pid_rep <- make_var_df(dfocc3_hca_rep, "cid_master")
df1_ps_rep <- make_var_df_partisan(dfocc3_hca_rep, "cid_master")


plt_title = "Partisan Polarization - AGNES Polarized Republican Firms"
tab_title1 = "Partisan Polarization - AGNES Polarized Republican Firms - Party ID"
tab_title2 = "Partisan Polarization - AGNES Polarized Republican Firms - Partisan Score"

vt_all_cidmaster <- var_sum_table(df1_pid_rep, 
                                  "output/tables/indiv_var_all_cidmaster_pid_hca_rep.tex",
                                  tab_title1)
vt_cycle_cidmaster <- var_cycle_table(df1_ps_rep, 
                                      "output/tables/indiv_var_cycle_cidmaster_ps_hca_rep.tex", 
                                      tab_title2)



gr_cid_master_pid <- make_var_graph_rep_pid(df1_pid_rep, "cid_master_pid_hca_rep", "Note: Party ID Used to Calculate Partisan Polarization", plt_title)
gr_cid_master_ps <- make_var_graph_rep_ps(df1_ps_rep, "cid_master_ps_hca_rep", "Note: Partisan Score Used to Calculate Partisan Polarization", plt_title)



##---------------------------- 
## Amphibious Firm Graphs

df1_pid_oth <- make_var_df(dfocc3_hca_oth, "cid_master")
df1_ps_oth <- make_var_df_partisan(dfocc3_hca_oth, "cid_master")


plt_title = "Partisan Polarization - AGNES Amphibious Firms"
tab_title1 = "Partisan Polarization - AGNES Amphibious Firms - Party ID"
tab_title2 = "Partisan Polarization - AGNES Amphibious Firms - Partisan Score"

vt_all_cidmaster <- var_sum_table(df1_pid_oth, 
                                  "output/tables/indiv_var_all_cidmaster_pid_hca_oth.tex",
                                  tab_title1)
vt_cycle_cidmaster <- var_cycle_table(df1_ps_oth, 
                                      "output/tables/indiv_var_cycle_cidmaster_ps_hca_oth.tex", 
                                      tab_title2)



gr_cid_master_pid <- make_var_graph_oth_pid(df1_pid_oth, "cid_master_pid_hca_oth", "Note: Party ID Used to Calculate Partisan Polarization", plt_title)
gr_cid_master_ps <- make_var_graph_oth_ps(df1_ps_oth, "cid_master_ps_hca_oth", "Note: Partisan Score Used to Calculate Partisan Polarization", plt_title)
