####################################
## Load Contrib SOURCE
####################################

#source("indiv_source.R")
source("indiv_partisan_functions.R")

colors_neutral = rev(brewer.pal(n = 8, name = "Purples")[5:8])
colors_dem = rev(brewer.pal(n = 8, name = "Blues")[5:8])
colors_rep = rev(brewer.pal(n = 8, name = "Reds")[5:8])


#############################
## 2004-2018 - POST HCA
#############################


##---------------------------- 
## All Firms

df1_mean_pid_base <- make_mean_pid_df(df_hca_0418_all, "cid_master")
df1_mean_ps_base <- make_mean_ps_df(df_hca_0418_all, "cid_master")


plt_title1 = "Average Partisanship - All Firms"
plt_title2 = "Average P (PID)artisanship - All Firms" (PS)

gr_agnes_pid <- make_mean_graph_base_pid(df1_mean_pid_base, "agnes_pid_hca_0418_base", "Note: Party ID Used to Calculate Partisanship", plt_title1)
gr_agnes_ps <- make_mean_graph_base_ps(df1_mean_ps_base, "agnes_ps_hca_0418_base", "Note: Partisan Score Used to Calculate Partisanship", plt_title2)



##---------------------------- 
## Democratic Firm Graphs

df1_mean_pid_dem <- make_mean_pid_df(df_hca_0418_dem, "cid_master")
df1_mean_ps_dem <- make_mean_ps_df(df_hca_0418_dem, "cid_master")


plt_title1 = "Average Partisanship - AGNES (2004-2018) Democratic Firms (PID)"
plt_title2 = "Average Partisanship - AGNES (2004-2018) Democratic Firms (PS)"

gr_agnes_pid <- make_mean_graph_dem_pid(df1_mean_pid_dem, "agnes_pid_hca_0418_dem", "Note: Party ID Used to Calculate Partisanship", plt_title1)
gr_agnes_ps <- make_mean_graph_dem_ps(df1_mean_ps_dem, "agnes_ps_hca_0418_dem", "Note: Partisan Score Used to Calculate Partisanship", plt_title2)




##---------------------------- 
## Republican Firm Graphs

df1_mean_pid_rep <-make_mean_pid_df(df_hca_0418_rep, "cid_master")
df1_mean_ps_rep <- make_mean_ps_df(df_hca_0418_rep, "cid_master")


plt_title1 = "Average Partisanship - AGNES (2004-2018) Republican Firms (PID)"
plt_title2 = "Average Partisanship - AGNES (2004-2018) Republican Firms (PS)"

gr_agnes_pid <- make_mean_graph_rep_pid(df1_mean_pid_rep, "agnes_pid_hca_0418_rep", "Note: Party ID Used to Calculate Partisanship", plt_title1)
gr_agnes_ps <- make_mean_graph_rep_ps(df1_mean_ps_rep, "agnes_ps_hca_0418_rep", "Note: Partisan Score Used to Calculate Partisanship", plt_title2)



##---------------------------- 
## Amphibious Firm Graphs

df1_mean_pid_oth <-make_mean_pid_df(df_hca_0418_oth, "cid_master")
df1_mean_ps_oth <- make_mean_ps_df(df_hca_0418_oth, "cid_master")


plt_title1 = "Average Partisanship - AGNES (2004-2018) Amphibious Firms (PID)"
plt_title2 = "Average Partisanship - AGNES (2004-2018) Amphibious Firms (PS)"

gr_agnes_pid <- make_mean_graph_oth_pid(df1_mean_pid_oth, "agnes_pid_hca_0418_oth", "Note: Party ID Used to Calculate Partisanship", plt_title1)
gr_agnes_ps <- make_mean_graph_oth_ps(df1_mean_ps_oth, "agnes_ps_hca_0418_oth", "Note: Partisan Score Used to Calculate Partisanship", plt_title2)





#############################
## 2010-2018 - POST HCA
#############################


##---------------------------- 
## All Firms

df1_mean_pid_base <- make_mean_pid_df(df_hca_1018_all, "cid_master")
df1_mean_ps_base <- make_mean_ps_df(df_hca_1018_all, "cid_master")


plt_title1 = "Average Partisanship - All Firms"
plt_title2 = "Average P (PID)artisanship - All Firms" (PS)

gr_agnes_pid <- make_mean_graph_base_pid(df1_mean_pid_base, "agnes_pid_hca_1018_base", "Note: Party ID Used to Calculate Partisanship", plt_title1)
gr_agnes_ps <- make_mean_graph_base_ps(df1_mean_ps_base, "agnes_ps_hca_1018_base", "Note: Partisan Score Used to Calculate Partisanship", plt_title2)



##---------------------------- 
## Democratic Firm Graphs

df1_mean_pid_dem <- make_mean_pid_df(df_hca_1018_dem, "cid_master")
df1_mean_ps_dem <- make_mean_ps_df(df_hca_1018_dem, "cid_master")


plt_title1 = "Average Partisanship - AGNES (2010-2018) Democratic Firms (PID)"
plt_title2 = "Average Partisanship - AGNES (2010-2018) Democratic Firms (PS)"

gr_agnes_pid <- make_mean_graph_dem_pid(df1_mean_pid_dem, "agnes_pid_hca_1018_dem", "Note: Party ID Used to Calculate Partisanship", plt_title1)
gr_agnes_ps <- make_mean_graph_dem_ps(df1_mean_ps_dem, "agnes_ps_hca_1018_dem", "Note: Partisan Score Used to Calculate Partisanship", plt_title2)




##---------------------------- 
## Republican Firm Graphs

df1_mean_pid_rep <-make_mean_pid_df(df_hca_1018_rep, "cid_master")
df1_mean_ps_rep <- make_mean_ps_df(df_hca_1018_rep, "cid_master")


plt_title1 = "Average Partisanship - AGNES (2010-2018) Republican Firms (PID)"
plt_title2 = "Average Partisanship - AGNES (2010-2018) Republican Firms (PS)"

gr_agnes_pid <- make_mean_graph_rep_pid(df1_mean_pid_rep, "agnes_pid_hca_1018_rep", "Note: Party ID Used to Calculate Partisanship", plt_title1)
gr_agnes_ps <- make_mean_graph_rep_ps(df1_mean_ps_rep, "agnes_ps_hca_1018_rep", "Note: Partisan Score Used to Calculate Partisanship", plt_title2)



##---------------------------- 
## Amphibious Firm Graphs

df1_mean_pid_oth <-make_mean_pid_df(df_hca_1018_oth, "cid_master")
df1_mean_ps_oth <- make_mean_ps_df(df_hca_1018_oth, "cid_master")


plt_title1 = "Average Partisanship - AGNES (2010-2018) Amphibious Firms (PID)"
plt_title2 = "Average Partisanship - AGNES (2010-2018) Amphibious Firms (PS)"

gr_agnes_pid <- make_mean_graph_oth_pid(df1_mean_pid_oth, "agnes_pid_hca_1018_oth", "Note: Party ID Used to Calculate Partisanship", plt_title1)
gr_agnes_ps <- make_mean_graph_oth_ps(df1_mean_ps_oth, "agnes_ps_hca_1018_oth", "Note: Partisan Score Used to Calculate Partisanship", plt_title2)


