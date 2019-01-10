####################################
## Load Contrib SOURCE
####################################

source("indiv_source.R")
source("indiv_partisan_functions.R")

colors_neutral = rev(brewer.pal(n = 8, name = "Purples")[5:8])
colors_dem = rev(brewer.pal(n = 8, name = "Blues")[5:8])
colors_rep = rev(brewer.pal(n = 8, name = "Reds")[5:8])


#############################
## CID MASTER - POST HCA
#############################


##---------------------------- 
## All Firms

df1_mean_pid_base <- make_mean_pid_df(dfocc3_hca_all, "cid_master")
df1_mean_ps_base <- make_mean_ps_df(dfocc3_hca_all, "cid_master")


plt_title = "Average Partisanship - All Firms"


gr_cid_master_pid <- make_mean_graph_base_pid(df1_mean_pid_base, "cid_master_pid_hca_base", "Note: Party ID Used to Calculate Partisanship", plt_title)
gr_cid_master_ps <- make_mean_graph_base_ps(df1_mean_ps_base, "cid_master_ps_hca_base", "Note: Partisan Score Used to Calculate Partisanship", plt_title)



##---------------------------- 
## Democratic Firm Graphs

df1_mean_pid_dem <- make_mean_pid_df(dfocc3_hca_dem, "cid_master")
df1_mean_ps_dem <- make_mean_ps_df(dfocc3_hca_dem, "cid_master")


plt_title = "Average Partisanship - AGNES Polarized Democratic Firms"


gr_cid_master_pid <- make_mean_graph_dem_pid(df1_mean_pid_dem, "cid_master_pid_hca_dem", "Note: Party ID Used to Calculate Partisanship", plt_title)
gr_cid_master_ps <- make_mean_graph_dem_ps(df1_mean_ps_dem, "cid_master_ps_hca_dem", "Note: Partisan Score Used to Calculate Partisanship", plt_title)




##---------------------------- 
## Republican Firm Graphs

df1_mean_pid_rep <-make_mean_pid_df(dfocc3_hca_rep, "cid_master")
df1_mean_ps_rep <- make_mean_ps_df(dfocc3_hca_rep, "cid_master")


plt_title = "Average Partisanship - AGNES Polarized Republican Firms"


gr_cid_master_pid <- make_mean_graph_rep_pid(df1_mean_pid_rep, "cid_master_pid_hca_rep", "Note: Party ID Used to Calculate Partisanship", plt_title)
gr_cid_master_ps <- make_mean_graph_rep_ps(df1_mean_ps_rep, "cid_master_ps_hca_rep", "Note: Partisan Score Used to Calculate Partisanship", plt_title)



##---------------------------- 
## Amphibious Firm Graphs

df1_mean_pid_oth <-make_mean_pid_df(dfocc3_hca_oth, "cid_master")
df1_mean_ps_oth <- make_mean_ps_df(dfocc3_hca_oth, "cid_master")


plt_title = "Average Partisanship - AGNES Amphibious Firms"


gr_cid_master_pid <- make_mean_graph_oth_pid(df1_mean_pid_oth, "cid_master_pid_hca_oth", "Note: Party ID Used to Calculate Partisanship", plt_title)
gr_cid_master_ps <- make_mean_graph_oth_ps(df1_mean_ps_oth, "cid_master_ps_hca_oth", "Note: Partisan Score Used to Calculate Partisanship", plt_title)
