####################################
## Load Contrib SOURCE
####################################

source("indiv_source.R")
source("indiv_vartab_varplot_functions.R")


colors_base <- pal_tableau(pal = "Tableau10")(8)

####################################
## Make Variance Tables + Graphs
####################################

##Number Filter 
nf = 0
df_analysis <- df_filtered %>%
  filter(n_indiv_raw >= nf) %>%
  filter(n_indiv_pid >= nf) %>% 
  filter(n_indiv_ps >= nf) %>% 
  filter(n_contrib >= nf) 


df_check <- df_analysis %>% 
  count(cid_master, cycle)


##Year Filter & N Filter
df_1980_constant <- get_cid_contant_n(df_filtered, 10)
df_analysis <- left_join(df_1980_constant, df_filtered)




#############################
## CID MASTER - 1980, N10
#############################

df1_pid <- make_var_df(df_analysis, "cid_master")
df1_ps <- make_var_df_partisan(df_analysis, "cid_master")

title1 = "Partisan Polarization (PID) - 1980 Firms"
title2 = "Partisan Polarization (PS) - 1980 Firms"
sub = "1980 Constant Firms, Unclassified"


gr_cid_master_pid <- make_var_graph_base_pid(df1_pid, "cid_master_pid_1980n10", title1)
gr_cid_master_ps <- make_var_graph_base_ps(df1_ps, "cid_master_ps_1980n10", title2)






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







