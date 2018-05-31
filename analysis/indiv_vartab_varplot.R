####################################
## Load Contrib SOURCE
####################################

source("indiv_source.R")




########################################
#Variance Table + Graph Functions
########################################

##VARIANCE DF FUNCTION

make_var_df <- function(input_df, company_var){
  require("dplyr")
  require("lazyeval")
  
  #Get Variance by Organization Levels
  
  selvars = list('cycle', company_var, 'pid2', 'occ3')
  groupvars = list('cycle', company_var, 'occ')
  
  df1a <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(pid2),
           !is.na(occ3)) %>%
    mutate(occ = occ3) %>% 
    group_by_(.dots = groupvars) %>% 
    summarize(varpid = var(as.numeric(pid2)))
  
  #Get Variance All Levels
  df1b <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(pid2),
           !is.na(occ3)) %>%
    mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
    mutate(occ = occ4) %>%
    group_by_(.dots = groupvars) %>% 
    summarize(varpid = var(as.numeric(pid2)))
  
  df1 <- rbind(df1a, df1b) %>%
    #remove "others" from pre 2004, only all exists before levels can be det.
    mutate(occ = ifelse(occ == "OTHERS" & cycle < 2004, NA, as.character(occ))) %>%
    mutate(occ = factor(occ,
                        levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL"))) %>%
    filter(!is.na(occ))
  
  return(df1)
}


make_var_df_partisan <- function(input_df, company_var){
  require("dplyr")
  require("lazyeval")
  
  #Get Variance by Organization Levels
  
  selvars = list('cycle', company_var, 'partisan_score', 'occ3')
  groupvars = list('cycle', company_var, 'occ')
  
  df1a <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(partisan_score),
           !is.na(occ3)) %>%
    mutate(occ = occ3) %>% 
    group_by_(.dots = groupvars) %>% 
    summarize(varpid = var(as.numeric(partisan_score)))
  
  #Get Variance All Levels
  df1b <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(partisan_score),
           !is.na(occ3)) %>%
    mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
    mutate(occ = occ4) %>%
    group_by_(.dots = groupvars) %>% 
    summarize(varpid = var(as.numeric(partisan_score)))
  
  df1 <- rbind(df1a, df1b) %>%
    #remove "others" from pre 2004, only all exists before levels can be det.
    mutate(occ = ifelse(occ == "OTHERS" & cycle < 2004, NA, as.character(occ))) %>%
    mutate(occ = factor(occ,
                        levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL"))) %>%
    filter(!is.na(occ))
  
  return(df1)
}




make_partisan_hist_df <- function(input_df, company_var, party_var){
  require("dplyr")
  require("lazyeval")
  
  #Get Variance by Organization Levels
  
  selvars = list('cycle', company_var, 'partisan_score', 'occ3')
  groupvars = list('cycle', company_var, 'occ')
  
  df1a <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(partisan_score),
           !is.na(occ3)) %>%
    mutate(occ = occ3) %>% 
    group_by_(.dots = groupvars) 
    #summarize(varpid = var(as.numeric(partisan_score)))
  
  #Get Variance All Levels
  df1b <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(partisan_score),
           !is.na(occ3)) %>%
    mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
    mutate(occ = occ4) %>%
    group_by_(.dots = groupvars) 
    #summarize(varpid = var(as.numeric(partisan_score)))
  
  df1 <- rbind(df1a, df1b) %>%
    #remove "others" from pre 2004, only all exists before levels can be det.
    mutate(occ = ifelse(occ == "OTHERS" & cycle < 2004, NA, as.character(occ))) %>%
    mutate(occ = factor(occ,
                        levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL"))) %>%
    filter(!is.na(occ))
  
  return(df1)
}



##VARIANCE TABLE FUNCTIONS
var_sum_table <- function(df, 
                          filepath="output/vartable1.tex", 
                          tabtitle="title") {
  vartab <- df %>% 
    group_by(occ) %>% 
    summarise(meanvar = mean(varpid, na.rm = T),
              medvar = median(varpid, na.rm = T),
              sdvar = sd(varpid, na.rm = T)
    ) %>% 
    rename("Organizational Hierarchy" = occ,
           "Mean Variance" = meanvar,
           "Median Variance" = medvar,
           "SD" = sdvar)
  
  #make latex table
  save_stargazer(filepath,
                 as.data.frame(vartab), header=FALSE,
                 type = "latex", 
                 digits = 3, summary = FALSE,
                 font.size = "scriptsize",
                 title = tabtitle )
  
  return(vartab)
}


var_cycle_table <- function(df, 
                            filepath="output/vartable2.tex", 
                            tabtitle="title") {
  vartab <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(varpid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    spread(cycle, meanvar) %>% 
    rename("Organizational Hierarchy" = occ)
  
  #make latex table
  save_stargazer(filepath,
                 as.data.frame(vartab), header=FALSE,
                 type = "latex", 
                 digits = 3, summary = FALSE,
                 font.size = "scriptsize",
                 title = tabtitle )
  
  return(vartab)
}



##VARIANCE GRAPH FUNCTIONS

make_var_graph <- function(df, plt_type="cid_master", plt_caption=""){

  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  plt_title = "Variance of Within-Company Individual Contributions by Occupation and Election Cycle"
    
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(varpid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) 
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), meanvar)) +
    #geom_point(aes(shape=cid), alpha=0.5) +
    geom_smooth(color='#B28E02', alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    #scale_color_manual(values=c("#0F6D0C", "#BF1200", "#BF1200", "#BF1200" )) +
    #scale_color_jama() +
    scale_color_npg() +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    #scale_x_datetime(date_labels = "%Y", date_breaks = "2 year", limits = lims) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab("Variance of Company Partisan Contributions") +
    labs(title = plt_title,
         caption = plt_caption) +
    theme(legend.position="bottom") +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(legend.title=element_blank()) + 
    theme(legend.position="bottom") +
    theme(plot.title = element_text(hjust = 0.5))
  
  
  ggsave(outfile, width = 10, height = 6)
  
  return(g)
  
}




####################################
## Make Variance Tables + Graphs
####################################



#############################
## CID MASTER
#############################

df1_pid <- make_var_df(dfocc3, "cid_master")
df1_ps <- make_var_df_partisan(dfocc3, "cid_master")
df1_part_hist <- make_partisan_hist_df(dfocc3, "cid_master")

vt_all_cidmaster <- var_sum_table(df1_pid, 
                                  "output/tables/indiv_var_all_cidmaster_pid.tex", 
                                  "Variance of Individual Contributor Partisanship (Major Parties) by Organizational Hierarchy - CID Master")
vt_cycle_cidmaster <- var_cycle_table(df1_ps, 
                                      "output/tables/indiv_var_cycle_cidmaster_ps.tex", 
                                      "Variance of Individual Contributor Partisanship (Partisan Score) by Occupation and Year - CID Master")




gr_cid_master_pid <- make_var_graph(df1_pid, "cid_master_pid", "Note: Companies Identified Using - CID_MASTER")
gr_cid_master_ps <- make_var_graph(df1_ps, "cid_master_ps", "Note: Companies Identified Using - CID_MASTER")





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





