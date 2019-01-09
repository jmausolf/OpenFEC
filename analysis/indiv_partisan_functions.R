####################################
## Load Contrib SOURCE
####################################

#source("indiv_source.R")

library(RColorBrewer)


########################################
#Variance Table + Graph Functions
########################################

##VARIANCE DF FUNCTION

make_mean_pid_df <- function(input_df, company_var){
  require("dplyr")
  require("lazyeval")
  
  #Get Mean by Organization Levels
  
  selvars = list('cycle', company_var, 'pid2', 'occ3')
  groupvars = list('cycle', company_var, 'occ')
  
  df1a <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(pid2),
           !is.na(occ3)) %>%
    mutate(occ = occ3) %>% 
    mutate(pid2_bin = if_else(pid2 == "DEM", 0, 1, missing = NULL)) %>% 
    group_by_(.dots = groupvars) %>% 
    summarize(mean_pid = mean(as.numeric(pid2_bin)))
  
  #Get Mean All Levels
  df1b <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(pid2),
           !is.na(occ3)) %>%
    mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
    mutate(occ = occ4) %>%
    mutate(pid2_bin = if_else(pid2 == "DEM", 0, 1, missing = NULL)) %>% 
    group_by_(.dots = groupvars) %>% 
    summarize(mean_pid = mean(as.numeric(pid2_bin)))
  
  df1 <- rbind(df1a, df1b) %>%
    #remove "others" from pre 2004, only all exists before levels can be det.
    mutate(occ = ifelse(occ == "OTHERS" & cycle < 2004, NA, as.character(occ))) %>%
    mutate(occ = factor(occ,
                        levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL"))) %>%
    filter(!is.na(occ))
  
  return(df1)
}


make_mean_ps_df <- function(input_df, company_var){
  require("dplyr")
  require("lazyeval")
  
  #Get Mean by Organization Levels
  
  selvars = list('cycle', company_var, 'partisan_score', 'occ3')
  groupvars = list('cycle', company_var, 'occ')
  
  df1a <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(partisan_score),
           !is.na(occ3)) %>%
    mutate(occ = occ3) %>% 
    group_by_(.dots = groupvars) %>% 
    summarize(mean_ps = mean(as.numeric(partisan_score)))
  
  #Get Mean All Levels
  df1b <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(partisan_score),
           !is.na(occ3)) %>%
    mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
    mutate(occ = occ4) %>%
    group_by_(.dots = groupvars) %>% 
    summarize(mean_ps = mean(as.numeric(partisan_score)))
  
  df1 <- rbind(df1a, df1b) %>%
    #remove "others" from pre 2004, only all exists before levels can be det.
    mutate(occ = ifelse(occ == "OTHERS" & cycle < 2004, NA, as.character(occ))) %>%
    mutate(occ = factor(occ,
                        levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL"))) %>%
    filter(!is.na(occ))
  
  return(df1)
}




##MEAN GRAPH FUNCTIONS

##----------------------------  
## Base Graph - Pre HCA

make_mean_graph_base_pid <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){

  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_mean_partisan_occ", out_by)
  
  df_mean_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(avgparty = mean(mean_pid, na.rm = T)) %>%
    filter(!is.nan(avgparty))
  
  g <- ggplot(df_mean_cycle_graph, aes(make_datetime(cycle), avgparty)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_base) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0, 1.0)) +
    xlab("Contribution Cycle") +
    ylab("Avg. Party ID: [DEM = 0, REP = 1]") +
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


make_mean_graph_base_ps <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){

  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_mean_partisan_occ", out_by)
  
  #plt_title = "Variance of Within-Company Individual Contributions by Occupation and Election Cycle"
    
  df_mean_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(avgparty = mean(mean_ps, na.rm = T)) %>%
    filter(!is.nan(avgparty))
  
  g <- ggplot(df_mean_cycle_graph, aes(make_datetime(cycle), avgparty)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_base) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(-1.0, 1.0)) +
    xlab("Contribution Cycle") +
    ylab("Avg. Partisan Score: [DEM = -1, REP = 1]") +
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

make_mean_graph_dem_pid <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_mean_partisan_occ", out_by)
  
  df_mean_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(avgparty = mean(mean_pid, na.rm = T)) %>%
    filter(!is.nan(avgparty))
  
  g <- ggplot(df_mean_cycle_graph, aes(make_datetime(cycle), avgparty)) +
    geom_smooth(color="#2129B0", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_dem) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab("Avg. Party ID: [DEM = 0, REP = 1]") +
    scale_y_continuous(limits = c(0, 1.0)) +
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


make_mean_graph_dem_ps <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_mean_partisan_occ", out_by)
  
  df_mean_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(avgparty = mean(mean_ps, na.rm = T)) %>%
    filter(!is.nan(avgparty))
  
  g <- ggplot(df_mean_cycle_graph, aes(make_datetime(cycle), avgparty)) +
    geom_smooth(color="#2129B0", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_dem) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab("Avg. Partisan Score: [DEM = -1, REP = 1]") +
    scale_y_continuous(limits = c(-1.0, 1.0)) +
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

make_mean_graph_rep_pid <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_mean_partisan_occ", out_by)
  
  df_mean_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(avgparty = mean(mean_pid, na.rm = T)) %>%
    filter(!is.nan(avgparty))
  
  g <- ggplot(df_mean_cycle_graph, aes(make_datetime(cycle), avgparty)) +
    geom_smooth(color="#BF1200", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_rep) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab("Avg. Party ID: [DEM = 0, REP = 1]") +
    scale_y_continuous(limits = c(0, 1.0)) +
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


make_mean_graph_rep_ps <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_mean_partisan_occ", out_by)
  
  df_mean_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(avgparty = mean(mean_ps, na.rm = T)) %>%
    filter(!is.nan(avgparty))
  
  g <- ggplot(df_mean_cycle_graph, aes(make_datetime(cycle), avgparty)) +
    geom_smooth(color="#BF1200", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_rep) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab("Avg. Partisan Score: [DEM = -1, REP = 1]") +
    scale_y_continuous(limits = c(-1.0, 1.0)) +
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

make_mean_graph_oth_pid <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_mean_partisan_occ", out_by)
  
  df_mean_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(avgparty = mean(mean_pid, na.rm = T)) %>%
    filter(!is.nan(avgparty))
  
  g <- ggplot(df_mean_cycle_graph, aes(make_datetime(cycle), avgparty)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_neutral) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab("Avg. Party ID: [DEM = 0, REP = 1]") +
    scale_y_continuous(limits = c(0, 1.0)) +
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


make_mean_graph_oth_ps <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_mean_partisan_occ", out_by)
  
  df_mean_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(avgparty = mean(mean_ps, na.rm = T)) %>%
    filter(!is.nan(avgparty))
  
  g <- ggplot(df_mean_cycle_graph, aes(make_datetime(cycle), avgparty)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    scale_color_manual(values=colors_neutral) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    xlab("Contribution Cycle") +
    ylab("Avg. Partisan Score: [DEM = -1, REP = 1]") +
    scale_y_continuous(limits = c(-1.0, 1.0)) +
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

