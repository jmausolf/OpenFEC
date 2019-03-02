####################################
## Load Contrib SOURCE
####################################

colors_neutral = rev(brewer.pal(n = 8, name = "Purples")[5:8])
colors_dem = rev(brewer.pal(n = 8, name = "Blues")[5:8])
# colors_rep = rev(brewer.pal(n = 8, name = "Reds")[5:8])
colors_rep = c("#700009", "#99000D", "#D80012", "#EF3B2C")

########################################
#Mean Data Functions
########################################

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


########################################
#Median Data Functions
########################################

make_median_pid_df <- function(input_df, company_var){
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
    summarize(median_pid = median(as.numeric(pid2_bin)))
  
  #Get Mean All Levels
  df1b <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(pid2),
           !is.na(occ3)) %>%
    mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
    mutate(occ = occ4) %>%
    mutate(pid2_bin = if_else(pid2 == "DEM", 0, 1, missing = NULL)) %>% 
    group_by_(.dots = groupvars) %>% 
    summarize(median_pid = median(as.numeric(pid2_bin)))
  
  df1 <- rbind(df1a, df1b) %>%
    #remove "others" from pre 2004, only all exists before levels can be det.
    mutate(occ = ifelse(occ == "OTHERS" & cycle < 2004, NA, as.character(occ))) %>%
    mutate(occ = factor(occ,
                        levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL"))) %>%
    filter(!is.na(occ))
  
  return(df1)
}


make_median_ps_df <- function(input_df, company_var){
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
    summarize(median_ps = median(as.numeric(partisan_score)))
  
  #Get Mean All Levels
  df1b <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(partisan_score),
           !is.na(occ3)) %>%
    mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
    mutate(occ = occ4) %>%
    group_by_(.dots = groupvars) %>% 
    summarize(median_ps = median(as.numeric(partisan_score)))
  
  df1 <- rbind(df1a, df1b) %>%
    #remove "others" from pre 2004, only all exists before levels can be det.
    mutate(occ = ifelse(occ == "OTHERS" & cycle < 2004, NA, as.character(occ))) %>%
    mutate(occ = factor(occ,
                        levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL"))) %>%
    filter(!is.na(occ))
  
  return(df1)
}


########################################
#Mean Graph Functions
########################################

make_mean_graph_base_pid <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){

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

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_base) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0, 1.0)) +
    geom_hline(yintercept = 0, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Mean Party ID: [DEM = 0, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)
  return(g)
  
}


make_mean_graph_base_ps <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){

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

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_base) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(-1.0, 1.0)) +
    geom_hline(yintercept = -1, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Mean Partisan Score: [DEM = -1, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)  
  return(g)
  
}


##----------------------------  
## Democratic Firm Graphs

make_mean_graph_dem_pid <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){
  
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

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_dem) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0, 1.0)) +
    geom_hline(yintercept = 0, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Mean Party ID: [DEM = 0, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=TRUE)
  return(g)
  
}


make_mean_graph_dem_ps <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){
  
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

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_dem) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(-1.0, 1.0)) +
    geom_hline(yintercept = -1, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Mean Partisan Score: [DEM = -1, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)  
  return(g)
  
}


##----------------------------  
## Republican Firm Graphs

make_mean_graph_rep_pid <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){
  
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

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_rep) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0, 1.0)) +
    geom_hline(yintercept = 0, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Mean Party ID: [DEM = 0, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)
  return(g)
  
}


make_mean_graph_rep_ps <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){
  
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

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_rep) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(-1.0, 1.0)) +
    geom_hline(yintercept = -1, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Mean Partisan Score: [DEM = -1, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)  
  return(g)

}

##----------------------------  
## Amphibious Firm Graphs

make_mean_graph_oth_pid <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){
  
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

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_neutral) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0, 1.0)) +
    geom_hline(yintercept = 0, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Mean Party ID: [DEM = 0, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)
  return(g)
  
}


make_mean_graph_oth_ps <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){
  
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

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_neutral) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(-1.0, 1.0)) +
    geom_hline(yintercept = -1, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Mean Partisan Score: [DEM = -1, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)  
  return(g)
  
}




########################################
#Median Graph Functions
########################################

make_median_graph_base_pid <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){

  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_median_partisan_occ", out_by)
  
  df_median_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(medianparty = mean(median_pid, na.rm = T)) %>%
    filter(!is.nan(medianparty))
  
  g <- ggplot(df_median_cycle_graph, aes(make_datetime(cycle), medianparty)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_base) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0, 1.0)) +
    geom_hline(yintercept = 0, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Median Party ID: [DEM = 0, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)
  return(g)
  
}


make_median_graph_base_ps <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){

  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_median_partisan_occ", out_by)
  
  #plt_title = "Variance of Within-Company Individual Contributions by Occupation and Election Cycle"
    
  df_median_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(medianparty = mean(median_ps, na.rm = T)) %>%
    filter(!is.nan(medianparty))
  
  g <- ggplot(df_median_cycle_graph, aes(make_datetime(cycle), medianparty)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_base) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(-1.0, 1.0)) +
    geom_hline(yintercept = -1, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Median Partisan Score: [DEM = -1, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)  
  return(g)
  
}


##----------------------------  
## Democratic Firm Graphs

make_median_graph_dem_pid <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_median_partisan_occ", out_by)
  
  df_median_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(medianparty = mean(median_pid, na.rm = T)) %>%
    filter(!is.nan(medianparty))
  
  g <- ggplot(df_median_cycle_graph, aes(make_datetime(cycle), medianparty)) +
    geom_smooth(color="#2129B0", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_dem) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0, 1.0)) +
    geom_hline(yintercept = 0, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Median Party ID: [DEM = 0, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=TRUE)
  return(g)
  
}


make_median_graph_dem_ps <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_median_partisan_occ", out_by)
  
  df_median_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(medianparty = mean(median_ps, na.rm = T)) %>%
    filter(!is.nan(medianparty))
  
  g <- ggplot(df_median_cycle_graph, aes(make_datetime(cycle), medianparty)) +
    geom_smooth(color="#2129B0", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_dem) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(-1.0, 1.0)) +
    geom_hline(yintercept = -1, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Median Partisan Score: [DEM = -1, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)  
  return(g)
  
}


##----------------------------  
## Republican Firm Graphs

make_median_graph_rep_pid <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_median_partisan_occ", out_by)
  
  df_median_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(medianparty = mean(median_pid, na.rm = T)) %>%
    filter(!is.nan(medianparty))
  
  g <- ggplot(df_median_cycle_graph, aes(make_datetime(cycle), medianparty)) +
    geom_smooth(color="#BF1200", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_rep) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0, 1.0)) +
    geom_hline(yintercept = 0, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Median Party ID: [DEM = 0, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)
  return(g)
  
}


make_median_graph_rep_ps <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_median_partisan_occ", out_by)
  
  df_median_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(medianparty = mean(median_ps, na.rm = T)) %>%
    filter(!is.nan(medianparty))
  
  g <- ggplot(df_median_cycle_graph, aes(make_datetime(cycle), medianparty)) +
    geom_smooth(color="#BF1200", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_rep) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(-1.0, 1.0)) +
    geom_hline(yintercept = -1, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Median Partisan Score: [DEM = -1, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)  
  return(g)

}

##----------------------------  
## Amphibious Firm Graphs

make_median_graph_oth_pid <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_median_partisan_occ", out_by)
  
  df_median_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(medianparty = mean(median_pid, na.rm = T)) %>%
    filter(!is.nan(medianparty))
  
  g <- ggplot(df_median_cycle_graph, aes(make_datetime(cycle), medianparty)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_neutral) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0, 1.0)) +
    geom_hline(yintercept = 0, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Median Party ID: [DEM = 0, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)
  return(g)
  
}


make_median_graph_oth_ps <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_median_partisan_occ", out_by)
  
  df_median_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(medianparty = mean(median_ps, na.rm = T)) %>%
    filter(!is.nan(medianparty))
  
  g <- ggplot(df_median_cycle_graph, aes(make_datetime(cycle), medianparty)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_neutral) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(-1.0, 1.0)) +
    geom_hline(yintercept = -1, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab("Median Partisan Score: [DEM = -1, REP = 1]") +
    labs(title = plt_title,
         caption = plt_caption) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=10, color="#222222")) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    theme(plot.title = element_text(hjust = 0.5))

  finalise_plot(g, plt_caption, outfile, footer=FALSE)  
  return(g)
  
}
