####################################
## Load Contrib SOURCE
####################################

#source("indiv_source.R")
#source("indiv_partisan_functions.R")



##---------------------------- 
## All Firms

if(base == TRUE){
    df1_mean_pid_base <- make_mean_pid_df(df_hca_all, "cid_master")
    df1_mean_ps_base <- make_mean_ps_df(df_hca_all, "cid_master")

    plt_title1 = "Mean Partisanship (PID) - All Firms"
    plt_title2 = "Mean Partisanship (PS) - All Firms"

    gr_agnes_pid <- make_mean_graph_base_pid(df1_mean_pid_base, paste("pid_hca_all_base", method, sep='_'), plt_title1)
    gr_agnes_ps <- make_mean_graph_base_ps(df1_mean_ps_base, paste("ps_hca_all_base", method, sep='_'), plt_title2)

} else {
    print("[*] skipping base graphs...")
}


##---------------------------- 
## Democratic Firm Graphs

df1_mean_pid_dem <- make_mean_pid_df(df_hca_all_dem, "cid_master")
df1_mean_ps_dem <- make_mean_ps_df(df_hca_all_dem, "cid_master")

plt_title1 = "Mean Partisanship (PID) - Democratic Firms"
plt_title2 = "Mean Partisanship (PS) - Democratic Firms"

gr_agnes_pid <- make_mean_graph_dem_pid(df1_mean_pid_dem, paste("pid_hca_all_dem", method, sep='_'), plt_title1)
gr_agnes_ps <- make_mean_graph_dem_ps(df1_mean_ps_dem, paste("ps_hca_all_dem", method, sep='_'), plt_title2)




##---------------------------- 
## Republican Firm Graphs

df1_mean_pid_rep <-make_mean_pid_df(df_hca_all_rep, "cid_master")
df1_mean_ps_rep <- make_mean_ps_df(df_hca_all_rep, "cid_master")

plt_title1 = "Mean Partisanship (PID) - Republican Firms"
plt_title2 = "Mean Partisanship (PS) - Republican Firms"

gr_agnes_pid <- make_mean_graph_rep_pid(df1_mean_pid_rep, paste("pid_hca_all_rep", method, sep='_'), plt_title1)
gr_agnes_ps <- make_mean_graph_rep_ps(df1_mean_ps_rep, paste("ps_hca_all_rep", method, sep='_'), plt_title2)



##---------------------------- 
## Amphibious Firm Graphs

if(oth == TRUE){

    df1_mean_pid_oth <-make_mean_pid_df(df_hca_all_oth, "cid_master")
    df1_mean_ps_oth <- make_mean_ps_df(df_hca_all_oth, "cid_master")

    plt_title1 = "Mean Partisanship (PID) - Amphibious Firms"
    plt_title2 = "Mean Partisanship (PS) - Amphibious Firms"

    gr_agnes_pid <- make_mean_graph_oth_pid(df1_mean_pid_oth, paste("pid_hca_all_oth", method, sep='_'), plt_title1)
    gr_agnes_ps <- make_mean_graph_oth_ps(df1_mean_ps_oth, paste("ps_hca_all_oth", method, sep='_'), plt_title2)

} else {
    print("[*] skipping amphibious graphs...")
}

#TODO Using the HCA Loop Data
#Impose a further classification
#Instead of just what the class is for a given year,
#Prior to Join, Create A Stable Dem, Stable Rep, Stable Amphibious
#DEM/OTHER --> REP (REP Converts) REP/OTHER --> DEM (Dem Converts)
#Waivering --> OTH REP DEM ---> Amphibious