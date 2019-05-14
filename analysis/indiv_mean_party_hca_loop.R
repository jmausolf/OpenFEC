####################################
## Load Contrib SOURCE
####################################

#source("indiv_source.R")
#source("indiv_partisan_functions.R")



##---------------------------- 
## All Firms

if(base == TRUE){
    df_mean_pid_base <- make_mean_pid_df(df_hca_all, "cid_master")
    df_mean_ps_base <- make_mean_ps_df(df_hca_all, "cid_master")

    plt_title1 = "All Firms - Mean Partisanship (PID)"
    plt_title2 = "All Firms - Mean Partisanship (PS)"

    make_partisan_graph(df_mean_pid_base, key="mean_pid", plt_type = "base",
                        file_label = paste("hca", method, sep='_'), plt_title = plt_title1)

    make_partisan_graph(df_mean_ps_base, key="mean_ps", plt_type = "base",
                        file_label = paste("hca", method, sep='_'), plt_title = plt_title2)

} else {
    print("[*] skipping base graphs...")
}


##---------------------------- 
## Democratic Firm Graphs

df_mean_pid_dem <- make_mean_pid_df(df_hca_all_dem, "cid_master")
df_mean_ps_dem <- make_mean_ps_df(df_hca_all_dem, "cid_master")

plt_title1 = "Democratic Firms - Mean Partisanship (PID)"
plt_title2 = "Democratic Firms - Mean Partisanship (PS)"

make_partisan_graph(df_mean_pid_dem, key="mean_pid", plt_type = "dem",
                    file_label = paste("hca", method, sep='_'), plt_title = plt_title1)

make_partisan_graph(df_mean_ps_dem, key="mean_ps", plt_type = "dem",
                    file_label = paste("hca", method, sep='_'), plt_title = plt_title2)



##---------------------------- 
## Republican Firm Graphs

df_mean_pid_rep <-make_mean_pid_df(df_hca_all_rep, "cid_master")
df_mean_ps_rep <- make_mean_ps_df(df_hca_all_rep, "cid_master")

plt_title1 = "Republican Firms - Mean Partisanship (PID)"
plt_title2 = "Republican Firms - Mean Partisanship (PS)"

make_partisan_graph(df_mean_pid_rep, key="mean_pid", plt_type = "rep",
                    file_label = paste("hca", method, sep='_'), plt_title = plt_title1)

make_partisan_graph(df_mean_ps_rep, key="mean_ps", plt_type = "rep",
                    file_label = paste("hca", method, sep='_'), plt_title = plt_title2)



##---------------------------- 
## Amphibious Firm Graphs

if(oth == TRUE){

    df_mean_pid_oth <-make_mean_pid_df(df_hca_all_oth, "cid_master")
    df_mean_ps_oth <- make_mean_ps_df(df_hca_all_oth, "cid_master")

    plt_title1 = "Amphibious Firms - Mean Partisanship (PID)"
    plt_title2 = "Amphibious Firms - Mean Partisanship (PS)"

    make_partisan_graph(df_mean_pid_oth, key="mean_pid", plt_type = "oth",
                        file_label = paste("hca", method, sep='_'), plt_title = plt_title1)

    make_partisan_graph(df_mean_ps_oth, key="mean_ps", plt_type = "oth",
                        file_label = paste("hca", method, sep='_'), plt_title = plt_title2)

} else {
    print("[*] skipping amphibious graphs...")
}

#TODO Using the HCA Loop Data
#Impose a further classification
#Instead of just what the class is for a given year,
#Prior to Join, Create A Stable Dem, Stable Rep, Stable Amphibious
#DEM/OTHER --> REP (REP Converts) REP/OTHER --> DEM (Dem Converts)
#Waivering --> OTH REP DEM ---> Amphibious