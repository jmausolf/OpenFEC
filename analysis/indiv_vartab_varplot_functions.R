####################################
## Load Contrib SOURCE
####################################

#source("indiv_source.R")

library(RColorBrewer)


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

##----------------------------  
## Base Graph - Pre HCA

make_var_graph_base_pid <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){

  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  #plt_title = "Variance of Within-Company Individual Contributions by Occupation and Election Cycle"
    
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(varpid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_base) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0.75, 0.97)) +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Party~ID)})) +
    labs(title = plt_title,
         caption = plt_caption) +
    theme_minimal() +
    theme(legend.position="bottom") +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  
  ggsave(outfile, width = 10, height = 6)
  
  return(g)
  
}


make_var_graph_base_ps <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){

  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  #plt_title = "Variance of Within-Company Individual Contributions by Occupation and Election Cycle"
    
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(varpid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_base) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0.2, 1.0)) +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Partisan~Score)})) +
    labs(title = plt_title,
         caption = plt_caption) +
    theme_minimal() +
    theme(legend.position="bottom") +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  
  ggsave(outfile, width = 10, height = 6)
  
  return(g)
  
}


##----------------------------  
## Democratic Firm Graphs

make_var_graph_dem_pid <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(varpid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#2129B0", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_dem) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Party~ID)})) +
    scale_y_continuous(limits = c(0.75, 0.97)) +
    labs(title = plt_title,
         caption = plt_caption) +
    theme_minimal() +
    theme(legend.position="bottom") +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  ggsave(outfile, width = 10, height = 6)
  
  return(g)
  
}


make_var_graph_dem_ps <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(varpid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#2129B0", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_dem) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Partisan~Score)})) +
    scale_y_continuous(limits = c(0.2, 1.0)) +
    labs(title = plt_title,
         caption = plt_caption) +
    theme_minimal() +
    theme(legend.position="bottom") +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  ggsave(outfile, width = 10, height = 6)
  
  return(g)
  
}


##----------------------------  
## Republican Firm Graphs

make_var_graph_rep_pid <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(varpid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#BF1200", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_rep) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Party~ID)})) +
    scale_y_continuous(limits = c(0.75, 0.97)) +
    labs(title = plt_title,
         caption = plt_caption) +
    theme_minimal() +
    theme(legend.position="bottom") +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  ggsave(outfile, width = 10, height = 6)
  
  return(g)
  
}


make_var_graph_rep_ps <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(varpid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#BF1200", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_rep) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Partisan~Score)})) +
    scale_y_continuous(limits = c(0.2, 1.0)) +
    labs(title = plt_title,
         caption = plt_caption) +
    theme_minimal() +
    theme(legend.position="bottom") +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  ggsave(outfile, width = 10, height = 6)
  
  return(g)
  
}

##----------------------------  
## Amphibious Firm Graphs

make_var_graph_oth_pid <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(varpid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_neutral) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Party~ID)})) +
    scale_y_continuous(limits = c(0.75, 0.97)) +
    labs(title = plt_title,
         caption = plt_caption) +
    theme_minimal() +
    theme(legend.position="bottom") +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  ggsave(outfile, width = 10, height = 6)
  
  return(g)
  
}


make_var_graph_oth_ps <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(varpid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_neutral) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Partisan~Score)})) +
    scale_y_continuous(limits = c(0.2, 1.0)) +
    labs(title = plt_title,
         caption = plt_caption) +
    theme_minimal() +
    theme(legend.position="bottom") +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  ggsave(outfile, width = 10, height = 6)
  
  return(g)
  
}

