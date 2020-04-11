####################################
## Load Contrib SOURCE
####################################

#source("indiv_source.R")
#source("indiv_partisan_functions.R")



#############################
## 2004-2018 - POST HCA
#############################


##---------------------------- 
## All Firms

df1_median_pid_base <- make_median_pid_df(df_hca_0418_all, "cid_master")
df1_median_ps_base <- make_median_ps_df(df_hca_0418_all, "cid_master")

plt_title1 = "Median Partisanship (PID) - All Firms"
plt_title2 = "Median Partisanship (PS) - All Firms"

gr_agnes_pid <- make_median_graph_base_pid(df1_median_pid_base, "agnes_pid_hca_0418_base", plt_title1)
gr_agnes_ps <- make_median_graph_base_ps(df1_median_ps_base, "agnes_ps_hca_0418_base", plt_title2)



##---------------------------- 
## Democratic Firm Graphs

df1_median_pid_dem <- make_median_pid_df(df_hca_0418_dem, "cid_master")
df1_median_ps_dem <- make_median_ps_df(df_hca_0418_dem, "cid_master")

plt_title1 = "Median Partisanship (PID) - Democratic Firms"
plt_title2 = "Median Partisanship (PS) - Democratic Firms"

gr_agnes_pid <- make_median_graph_dem_pid(df1_median_pid_dem, "agnes_pid_hca_0418_dem", plt_title1)
gr_agnes_ps <- make_median_graph_dem_ps(df1_median_ps_dem, "agnes_ps_hca_0418_dem", plt_title2)




##---------------------------- 
## Republican Firm Graphs

df1_median_pid_rep <-make_median_pid_df(df_hca_0418_rep, "cid_master")
df1_median_ps_rep <- make_median_ps_df(df_hca_0418_rep, "cid_master")

plt_title1 = "Median Partisanship (PID) - Republican Firms"
plt_title2 = "Median Partisanship (PS) - Republican Firms"

gr_agnes_pid <- make_median_graph_rep_pid(df1_median_pid_rep, "agnes_pid_hca_0418_rep", plt_title1)
gr_agnes_ps <- make_median_graph_rep_ps(df1_median_ps_rep, "agnes_ps_hca_0418_rep", plt_title2)



##---------------------------- 
## Amphibious Firm Graphs

df1_median_pid_oth <-make_median_pid_df(df_hca_0418_oth, "cid_master")
df1_median_ps_oth <- make_median_ps_df(df_hca_0418_oth, "cid_master")

plt_title1 = "Median Partisanship (PID) - Amphibious Firms"
plt_title2 = "Median Partisanship (PS) - Amphibious Firms"

gr_agnes_pid <- make_median_graph_oth_pid(df1_median_pid_oth, "agnes_pid_hca_0418_oth", plt_title1)
gr_agnes_ps <- make_median_graph_oth_ps(df1_median_ps_oth, "agnes_ps_hca_0418_oth", plt_title2)





#############################
## 2010-2018 - POST HCA
#############################


##---------------------------- 
## All Firms

df1_median_pid_base <- make_median_pid_df(df_hca_1018_all, "cid_master")
df1_median_ps_base <- make_median_ps_df(df_hca_1018_all, "cid_master")

plt_title1 = "Median Partisanship (PID) - All Firms"
plt_title2 = "Median Partisanship (PS) - All Firms"

gr_agnes_pid <- make_median_graph_base_pid(df1_median_pid_base, "agnes_pid_hca_1018_base", plt_title1)
gr_agnes_ps <- make_median_graph_base_ps(df1_median_ps_base, "agnes_ps_hca_1018_base", plt_title2)



##---------------------------- 
## Democratic Firm Graphs

df1_median_pid_dem <- make_median_pid_df(df_hca_1018_dem, "cid_master")
df1_median_ps_dem <- make_median_ps_df(df_hca_1018_dem, "cid_master")

plt_title1 = "Median Partisanship (PID) - Democratic Firms"
plt_title2 = "Median Partisanship (PS) - Democratic Firms"

gr_agnes_pid <- make_median_graph_dem_pid(df1_median_pid_dem, "agnes_pid_hca_1018_dem", plt_title1)
gr_agnes_ps <- make_median_graph_dem_ps(df1_median_ps_dem, "agnes_ps_hca_1018_dem", plt_title2)




##---------------------------- 
## Republican Firm Graphs

df1_median_pid_rep <-make_median_pid_df(df_hca_1018_rep, "cid_master")
df1_median_ps_rep <- make_median_ps_df(df_hca_1018_rep, "cid_master")


plt_title1 = "Median Partisanship (PID) - Republican Firms"
plt_title2 = "Median Partisanship (PS) - Republican Firms"

gr_agnes_pid <- make_median_graph_rep_pid(df1_median_pid_rep, "agnes_pid_hca_1018_rep", plt_title1)
gr_agnes_ps <- make_median_graph_rep_ps(df1_median_ps_rep, "agnes_ps_hca_1018_rep", plt_title2)



##---------------------------- 
## Amphibious Firm Graphs

df1_median_pid_oth <-make_median_pid_df(df_hca_1018_oth, "cid_master")
df1_median_ps_oth <- make_median_ps_df(df_hca_1018_oth, "cid_master")

plt_title1 = "Median Partisanship (PID) - Amphibious Firms"
plt_title2 = "Median Partisanship (PS) - Amphibious Firms"

gr_agnes_pid <- make_median_graph_oth_pid(df1_median_pid_oth, "agnes_pid_hca_1018_oth", plt_title1)
gr_agnes_ps <- make_median_graph_oth_ps(df1_median_ps_oth, "agnes_ps_hca_1018_oth", plt_title2)


