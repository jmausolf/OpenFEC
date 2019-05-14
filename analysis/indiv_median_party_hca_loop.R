####################################
## Load Contrib SOURCE
####################################

#source("indiv_source.R")
#source("indiv_partisan_functions.R")



##---------------------------- 
## All Firms

if(base == TRUE){
    df_median_pid_base <- make_median_pid_df(df_hca_all, "cid_master")
    df_median_ps_base <- make_median_ps_df(df_hca_all, "cid_master")

    plt_title1 = "All Firms - Median Partisanship (PID)"
    plt_title2 = "All Firms - Median Partisanship (PS)"

    make_partisan_graph(df_median_pid_base, key="median_pid", plt_type = "base",
                        file_label = paste("hca", method, sep='_'), plt_title = plt_title1)

    make_partisan_graph(df_median_ps_base, key="median_ps", plt_type = "base",
                        file_label = paste("hca", method, sep='_'), plt_title = plt_title2)

} else {
    print("[*] skipping base graphs...")
}


##---------------------------- 
## Democratic Firm Graphs

df_median_pid_dem <- make_median_pid_df(df_hca_all_dem, "cid_master")
df_median_ps_dem <- make_median_ps_df(df_hca_all_dem, "cid_master")

plt_title1 = "Democratic Firms - Median Partisanship (PID)"
plt_title2 = "Democratic Firms - Median Partisanship (PS)"

make_partisan_graph(df_median_pid_dem, key="median_pid", plt_type = "dem",
                    file_label = paste("hca", method, sep='_'), plt_title = plt_title1)

make_partisan_graph(df_median_ps_dem, key="median_ps", plt_type = "dem",
                    file_label = paste("hca", method, sep='_'), plt_title = plt_title2)



##---------------------------- 
## Republican Firm Graphs

df_median_pid_rep <-make_median_pid_df(df_hca_all_rep, "cid_master")
df_median_ps_rep <- make_median_ps_df(df_hca_all_rep, "cid_master")

plt_title1 = "Republican Firms - Median Partisanship (PID)"
plt_title2 = "Republican Firms - Median Partisanship (PS)"

make_partisan_graph(df_median_pid_rep, key="median_pid", plt_type = "rep",
                    file_label = paste("hca", method, sep='_'), plt_title = plt_title1)

make_partisan_graph(df_median_ps_rep, key="median_ps", plt_type = "rep",
                    file_label = paste("hca", method, sep='_'), plt_title = plt_title2)



##---------------------------- 
## Amphibious Firm Graphs

if(oth == TRUE){

    df_median_pid_oth <-make_median_pid_df(df_hca_all_oth, "cid_master")
    df_median_ps_oth <- make_median_ps_df(df_hca_all_oth, "cid_master")

    plt_title1 = "Amphibious Firms - Median Partisanship (PID)"
    plt_title2 = "Amphibious Firms - Median Partisanship (PS)"

    make_partisan_graph(df_median_pid_oth, key="median_pid", plt_type = "oth",
                        file_label = paste("hca", method, sep='_'), plt_title = plt_title1)

    make_partisan_graph(df_median_ps_oth, key="median_ps", plt_type = "oth",
                        file_label = paste("hca", method, sep='_'), plt_title = plt_title2)

} else {
    print("[*] skipping amphibious graphs...")
}
