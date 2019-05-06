####################################
## Load Contrib SOURCE
####################################

#source("indiv_source.R")
#source("indiv_partisan_functions.R")



##---------------------------- 
## All Firms

if(base == TRUE){
    df1_median_pid_base <- make_median_pid_df(df_hca_all, "cid_master")
    df1_median_ps_base <- make_median_ps_df(df_hca_all, "cid_master")

    plt_title1 = "Median Partisanship (PID) - All Firms"
    plt_title2 = "Median Partisanship (PS) - All Firms"

    gr_agnes_pid <- make_median_graph_base_pid(df1_median_pid_base, paste("pid_hca_all_base", method, sep='_'), plt_title1)
    gr_agnes_ps <- make_median_graph_base_ps(df1_median_ps_base, paste("ps_hca_all_base", method, sep='_'), plt_title2)

} else {
    print("[*] skipping base graphs...")
}


##---------------------------- 
## Democratic Firm Graphs

df1_median_pid_dem <- make_median_pid_df(df_hca_all_dem, "cid_master")
df1_median_ps_dem <- make_median_ps_df(df_hca_all_dem, "cid_master")

plt_title1 = "Median Partisanship (PID) - Democratic Firms"
plt_title2 = "Median Partisanship (PS) - Democratic Firms"

gr_agnes_pid <- make_median_graph_dem_pid(df1_median_pid_dem, paste("pid_hca_all_dem", method, sep='_'), plt_title1)
gr_agnes_ps <- make_median_graph_dem_ps(df1_median_ps_dem, paste("ps_hca_all_dem", method, sep='_'), plt_title2)




##---------------------------- 
## Republican Firm Graphs

df1_median_pid_rep <-make_median_pid_df(df_hca_all_rep, "cid_master")
df1_median_ps_rep <- make_median_ps_df(df_hca_all_rep, "cid_master")

plt_title1 = "Median Partisanship (PID) - Republican Firms"
plt_title2 = "Median Partisanship (PS) - Republican Firms"

gr_agnes_pid <- make_median_graph_rep_pid(df1_median_pid_rep, paste("pid_hca_all_rep", method, sep='_'), plt_title1)
gr_agnes_ps <- make_median_graph_rep_ps(df1_median_ps_rep, paste("ps_hca_all_rep", method, sep='_'), plt_title2)



##---------------------------- 
## Amphibious Firm Graphs

if(oth == TRUE){

    df1_median_pid_oth <-make_median_pid_df(df_hca_all_oth, "cid_master")
    df1_median_ps_oth <- make_median_ps_df(df_hca_all_oth, "cid_master")

    plt_title1 = "Median Partisanship (PID) - Amphibious Firms"
    plt_title2 = "Median Partisanship (PS) - Amphibious Firms"

    gr_agnes_pid <- make_median_graph_oth_pid(df1_median_pid_oth, paste("pid_hca_all_oth", method, sep='_'), plt_title1)
    gr_agnes_ps <- make_median_graph_oth_ps(df1_median_ps_oth, paste("ps_hca_all_oth", method, sep='_'), plt_title2)

} else {
    print("[*] skipping amphibious graphs...")
}
