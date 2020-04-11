####################################
## Load Contrib SOURCE
####################################

#source("indiv_source.R")
#source("indiv_vartab_varplot_functions.R")
#source("indiv_partisan_functions.R")


#############################
## 2004-2018 POST HCA
#############################



##---------------------------- 
## Democratic Firm Graphs

df1_pid_dem <- make_var_df(df_hca_0418_dem, "cid_master")
df1_ps_dem <- make_var_df_partisan(df_hca_0418_dem, "cid_master")

plt_title1 = "Partisan Polarization Democratic Firms (PID)"
plt_title2 = "Partisan Polarization Democratic Firms (PS)"

gr_agnes_pid <- make_var_graph_dem_pid(df1_pid_dem, "agnes_pid_hca_0418_dem", "Note: Party ID Used to Calculate Partisan Polarization", plt_title1)
gr_agnes_ps <- make_var_graph_dem_ps(df1_ps_dem, "agnes_ps_hca_0418_dem", "Note: Partisan Score Used to Calculate Partisan Polarization", plt_title2)




##---------------------------- 
## Republican Firm Graphs

df1_pid_rep <- make_var_df(df_hca_0418_rep, "cid_master")
df1_ps_rep <- make_var_df_partisan(df_hca_0418_rep, "cid_master")

plt_title1 = "Partisan Polarization Republican Firms (PID)"
plt_title2 = "Partisan Polarization Republican Firms (PS)"

gr_agnes_pid <- make_var_graph_rep_pid(df1_pid_rep, "agnes_pid_hca_0418_rep", "Note: Party ID Used to Calculate Partisan Polarization", plt_title1)
gr_agnes_ps <- make_var_graph_rep_ps(df1_ps_rep, "agnes_ps_hca_0418_rep", "Note: Partisan Score Used to Calculate Partisan Polarization", plt_title2)



##---------------------------- 
## Amphibious Firm Graphs

df1_pid_oth <- make_var_df(df_hca_0418_oth, "cid_master")
df1_ps_oth <- make_var_df_partisan(df_hca_0418_oth, "cid_master")

plt_title1 = "Partisan Polarization Amphibious Firms (PID)"
plt_title2 = "Partisan Polarization Amphibious Firms (PS)"

gr_agnes_pid <- make_var_graph_oth_pid(df1_pid_oth, "agnes_pid_hca_0418_oth", "Note: Party ID Used to Calculate Partisan Polarization", plt_title1)
gr_agnes_ps <- make_var_graph_oth_ps(df1_ps_oth, "agnes_ps_hca_0418_oth", "Note: Partisan Score Used to Calculate Partisan Polarization", plt_title2)




#############################
## 2010-2018 POST HCA
#############################


##---------------------------- 
## Democratic Firm Graphs

df1_pid_dem <- make_var_df(df_hca_1018_dem, "cid_master")
df1_ps_dem <- make_var_df_partisan(df_hca_1018_dem, "cid_master")

plt_title1 = "Partisan Polarization Democratic Firms (PID)"
plt_title2 = "Partisan Polarization Democratic Firms (PS)"

gr_agnes_pid <- make_var_graph_dem_pid(df1_pid_dem, "agnes_pid_hca_1018_dem", "Note: Party ID Used to Calculate Partisan Polarization", plt_title1)
gr_agnes_ps <- make_var_graph_dem_ps(df1_ps_dem, "agnes_ps_hca_1018_dem", "Note: Partisan Score Used to Calculate Partisan Polarization", plt_title2)




##---------------------------- 
## Republican Firm Graphs

df1_pid_rep <- make_var_df(df_hca_1018_rep, "cid_master")
df1_ps_rep <- make_var_df_partisan(df_hca_1018_rep, "cid_master")

plt_title1 = "Partisan Polarization Republican Firms (PID)"
plt_title2 = "Partisan Polarization Republican Firms (PS)"

gr_agnes_pid <- make_var_graph_rep_pid(df1_pid_rep, "agnes_pid_hca_1018_rep", "Note: Party ID Used to Calculate Partisan Polarization", plt_title1)
gr_agnes_ps <- make_var_graph_rep_ps(df1_ps_rep, "agnes_ps_hca_1018_rep", "Note: Partisan Score Used to Calculate Partisan Polarization", plt_title2)



##---------------------------- 
## Amphibious Firm Graphs

df1_pid_oth <- make_var_df(df_hca_1018_oth, "cid_master")
df1_ps_oth <- make_var_df_partisan(df_hca_1018_oth, "cid_master")

plt_title1 = "Partisan Polarization Amphibious Firms (PID)"
plt_title2 = "Partisan Polarization Amphibious Firms (PS)"

gr_agnes_pid <- make_var_graph_oth_pid(df1_pid_oth, "agnes_pid_hca_1018_oth", "Note: Party ID Used to Calculate Partisan Polarization", plt_title1)
gr_agnes_ps <- make_var_graph_oth_ps(df1_ps_oth, "agnes_ps_hca_1018_oth", "Note: Partisan Score Used to Calculate Partisan Polarization", plt_title2)



