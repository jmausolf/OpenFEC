####################################
## Load Contrib SOURCE
####################################

source("indiv_source.R")
source("indiv_vartab_varplot_functions.R")


colors_base <- pal_nejm("default")(8)
colors_base <- pal_aaas("default")(8)
#colors_base <- rev(pal_aaas("default")(8)[5:8])

####################################
## Make Variance Tables + Graphs
####################################



#############################
## CID MASTER
#############################

df1_pid <- make_var_df(dfocc, "cid_master")
df1_ps <- make_var_df_partisan(dfocc, "cid_master")
#df1_part_hist <- make_partisan_hist_df(dfocc, "cid_master")

plt_title = "Partisan Polarization - All Firms, Unclassified"
tab_title1 = "Partisan Polarization - All Firms, Unclassified - Party ID"
tab_title2 = "Partisan Polarization - All Firms, Unclassified - Partisan Score"

vt_all_cidmaster <- var_sum_table(df1_pid, 
                                  "output/tables/indiv_var_all_cidmaster_pid_hca_dem.tex",
                                  tab_title1)
vt_cycle_cidmaster <- var_cycle_table(df1_ps, 
                                      "output/tables/indiv_var_cycle_cidmaster_ps_hca_dem.tex", 
                                      tab_title2)



gr_cid_master_pid <- make_var_graph_base_pid(df1_pid, "cid_master_pid_base", "Note: Party ID Used to Calculate Partisan Polarization", plt_title)
gr_cid_master_ps <- make_var_graph_base_ps(df1_ps, "cid_master_ps_base", "Note: Partisan Score Used to Calculate Partisan Polarization", plt_title)






#############################
## CID
#############################

df1 <- make_var_df(dfocc3, "cid")

vt_all_cid <- var_sum_table(df1, 
                                  "output/tables/contrib_var_all_cid.tex", 
                                  "Variance of Major Party Contributions by Organizational Hierarchy - CID")
vt_cycle_cid <- var_cycle_table(df1, 
                                      "output/tables/contrib_var_cycle_cid.tex", 
                                      "Variance of Major Party Contributions by Occupation and Year - CID")


gr_cid <- make_var_graph(df1, "cid", "Note: Companies Identified Using - CID")



#Small Tables

#############################
## SMALL TAB | CID MASTER
#############################

dfocc3_small <- dfocc3 %>% 
  filter(cycle >= 2004)


df1 <- make_var_df(dfocc3_small, "cid_master")


vt_all_cidmaster_small <- var_sum_table(df1, 
                                  "output/tables/contrib_var_all_cidmaster_small.tex", 
                                  "Variance of Major Party Contributions by Organizational Hierarchy - CID Master")
vt_cycle_cidmaster_small <- var_cycle_table(df1, 
                                      "output/tables/contrib_var_cycle_cidmaster_small.tex", 
                                      "Variance of Major Party Contributions by Occupation and Year - CID Master")




#############################
## SMALL TAB | CID 
#############################

df1 <- make_var_df(dfocc3_small, "cid")

vt_all_cid_small <- var_sum_table(df1, 
                                        "output/tables/contrib_var_all_cid_small.tex", 
                                        "Variance of Major Party Contributions by Organizational Hierarchy - CID")
vt_cycle_cid_small <- var_cycle_table(df1, 
                                            "output/tables/contrib_var_cycle_cid_small.tex", 
                                            "Variance of Major Party Contributions by Occupation and Year - CID")







