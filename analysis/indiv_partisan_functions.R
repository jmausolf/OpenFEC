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

make_partisan_graph <- function(df_in, key, plt_type="base",
                                file_label="cid_master", plt_title="", plt_caption=""){
  
  #Set color by plot type
  if(plt_type == "base"){
    scol = "#3A084A"
    colors_vec = colors_base
  }
  
  if(plt_type == "dem"){
    scol = "#2129B0"
    colors_vec = colors_dem
  }
  
  if(plt_type == "rep"){
    scol = "#BF1200"
    colors_vec = colors_rep
  }
  
  if(plt_type == "oth"){
    scol = "#3A084A"
    colors_vec = colors_neutral
  }
  
  #Set ylim by key type
  if(key == "mean_pid"){
    y_lim = c(0, 1.0)
    y_int = 0.0
    y_axis_lab = "Mean Party ID: [DEM = 0, REP = 1]"
  }
  
  if(key == "median_pid"){
    y_lim = c(0, 1.0)
    y_int = 0.0
    y_axis_lab = "Median Party ID: [DEM = 0, REP = 1]"
  }
  
  if(key == "mean_ps"){
    y_lim = c(-1.0, 1.0)
    y_int = -1.0
    y_axis_lab = "Mean Partisan Score: [DEM = -1, REP = 1]"
  }
  
  if(key == "median_ps"){
    y_lim = c(-1.0, 1.0)
    y_int = -1.0
    y_axis_lab = "Median Partisan Score: [DEM = -1, REP = 1]"
  }
  
  key = sym(key)
  
  out_by = paste(plt_type, key, file_label, sep = "_")
  outfile <- wout("indiv_partisan_occ", out_by)
  
  
  df <- df_in %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(!!key, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(avgparty = meanvar)
  
  
  
  g <- ggplot(df, aes(make_datetime(cycle), avgparty)) +
    geom_smooth(color=scol, alpha=0.15, size=0.75) +
    geom_line(aes(color=occ), alpha=0.9) +
    
    #Add Point to Add the Shape by Occ
    geom_point(aes(shape=occ), alpha=1, size=3) +
    
    #Fill Each Occ Shape / Get Outline Independently
    geom_point(data = df %>% filter(occ == "CSUITE"), shape=21, alpha=1,
               pch=21, size=3, fill=colors_vec[1]) +
    geom_point(data = df %>% filter(occ == "MANAGEMENT"), shape=22, alpha=1,
               pch=21, size=3, fill=colors_vec[2]) +
    geom_point(data = df %>% filter(occ == "OTHERS"), shape=23, alpha=1,
               pch=21, size=3, fill=colors_vec[3]) +
    geom_point(data = df %>% filter(occ == "ALL"), shape=24, alpha=1,
               pch=21, size=3, fill=colors_vec[4]) +
    
    #Add bbcstyle
    bbc_style() +
    
    #Manual Scales
    scale_color_manual("", values=colors_vec, labels=occ_labels) +
    scale_shape_manual("", values=c(21, 22, 23, 24), labels=occ_labels) +
    scale_x_datetime(date_labels = "%Y",
                     #Make 1982 - 2018 every 4 years
                     date_breaks = "4 year"
                     # #Make 1980 - 2016 every 4 years
                     # breaks = seq(as.POSIXct("1980-01-01"),
                     #              as.POSIXct("2020-01-01"), "4 years")
    ) +
    scale_y_continuous(limits = y_lim) +
    
    #Xaxis Line
    geom_hline(yintercept = y_int, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab(y_axis_lab) +
    labs(title = plt_title,
         caption = plt_caption) +
    theme(plot.title = element_text(hjust = 0.5)) +
    
    #Adjust Legend Position
    theme(
      legend.spacing.x = unit(2.0, 'mm'),
      legend.text = element_text(size=18)
    ) +
    
    #Add x axis ticks
    theme(
      axis.ticks.x = element_line(colour = "#333333"), 
      axis.ticks.length =  unit(0.26, "cm"),
      axis.text = element_text(size=14, color="#222222")) +
    
    #Override the Legend Fill
    guides(shape = guide_legend(override.aes = list(fill = colors_vec)))
  
  finalise_plot(g, plt_caption, outfile, footer=FALSE)
  return(g)
  
}



make_competing_partisans_graph <- function(df_in_dem, df_in_rep, key, plt_type="dem_rep",
                                           file_label="", plt_title="", plt_caption=""){


#Set color by plot type
cols_grey1 <- DescTools::ColToGray(colors_rep)
scol_dem = "#2129B0"
scol_rep = "#BF1200"

out_by = paste(plt_type, key, file_label, sep = "_")
outfile <- wout("indiv_competing_partisans_occ", out_by)

  
#Set ylim by key type
if(key == "mean_pid"){
    y_lim = c(0, 1.0)
    y_int = 0.0
    y_axis_lab = "Mean Party ID: [DEM = 0, REP = 1]"
  }
  
if(key == "median_pid"){
    y_lim = c(0, 1.0)
    y_int = 0.0
    y_axis_lab = "Median Party ID: [DEM = 0, REP = 1]"
  }
  
if(key == "mean_ps"){
    y_lim = c(-1.0, 1.0)
    y_int = -1.0
    y_axis_lab = "Mean Partisan Score: [DEM = -1, REP = 1]"
  }

if(key == "median_ps"){
    y_lim = c(-1.0, 1.0)
    y_int = -1.0
    y_axis_lab = "Median Partisan Score: [DEM = -1, REP = 1]"
  }

key = sym(key)


df_dem <- df_in_dem %>% 
  group_by(occ, cycle) %>% 
  # summarise(meanvar = mean(mean_pid, na.rm = T)) %>%
  summarise(meanvar = mean(!!key, na.rm = T)) %>%
  filter(!is.nan(meanvar)) %>% 
  mutate(avgparty = meanvar)


df_rep <- df_in_rep %>% 
  group_by(occ, cycle) %>% 
  #summarise(meanvar = mean(mean_pid, na.rm = T)) %>%
  summarise(meanvar = mean(!!key, na.rm = T)) %>%
  filter(!is.nan(meanvar)) %>% 
  mutate(avgparty = meanvar) %>% 
  mutate(occ_rep = occ)


g <- ggplot(df_dem, aes(make_datetime(cycle), avgparty)) +
  
  #DEMS Data
  geom_smooth(data = df_dem, color=scol_dem, alpha=0.15, size=0.75) +
  
  #Add Each Occ Line Independently
  geom_line(data = df_dem %>% filter(occ == "CSUITE"), alpha=0.9, color=colors_dem[1]) +
  geom_line(data = df_dem %>% filter(occ == "MANAGEMENT"), alpha=0.9, color=colors_dem[2]) +
  geom_line(data = df_dem %>% filter(occ == "OTHERS"), alpha=0.9, color=colors_dem[3]) +
  geom_line(data = df_dem %>% filter(occ == "ALL"), alpha=0.9, color=colors_dem[4]) +
  
  #Add Point to Add the Shape by Occ
  geom_point(data = df_dem, aes(shape=occ), alpha=1, size=3) +
  
  #Fill Each Occ Shape / Get Outline Independently
  geom_point(data = df_dem %>% filter(occ == "CSUITE"), shape=21, alpha=1,
             pch=21, size=3, fill=colors_dem[1]) +
  geom_point(data = df_dem %>% filter(occ == "MANAGEMENT"), shape=22, alpha=1,
             pch=21, size=3, fill=colors_dem[2]) +
  geom_point(data = df_dem %>% filter(occ == "OTHERS"), shape=23, alpha=1,
             pch=21, size=3, fill=colors_dem[3]) +
  geom_point(data = df_dem %>% filter(occ == "ALL"), shape=24, alpha=1,
             pch=21, size=3, fill=colors_dem[4]) +
  
  
  #REP Data
  geom_smooth(data = df_rep, color=scol_rep, alpha=0.15, size=0.75) +
  
  #Add Each Occ Line Independently
  geom_line(data = df_rep %>% filter(occ == "CSUITE"), alpha=0.9, color=colors_rep[1]) +
  geom_line(data = df_rep %>% filter(occ == "MANAGEMENT"), alpha=0.9, color=colors_rep[2]) +
  geom_line(data = df_rep %>% filter(occ == "OTHERS"), alpha=0.9, color=colors_rep[3]) +
  geom_line(data = df_rep %>% filter(occ == "ALL"), alpha=0.9, color=colors_rep[4]) +
  
  #Add Point to Add the Shape by Occ
  geom_point(data = df_rep, aes(shape=occ), alpha=1, size=3) +
  
  #Fill Each Occ Shape / Get Outline Independently
  geom_point(data = df_rep %>% filter(occ == "CSUITE"), shape=21, alpha=1,
             pch=21, size=3, fill=colors_rep[1]) +
  geom_point(data = df_rep %>% filter(occ == "MANAGEMENT"), shape=22, alpha=1,
             pch=21, size=3, fill=colors_rep[2]) +
  geom_point(data = df_rep %>% filter(occ == "OTHERS"), shape=23, alpha=1,
             pch=21, size=3, fill=colors_rep[3]) +
  geom_point(data = df_rep %>% filter(occ == "ALL"), shape=24, alpha=1,
             pch=21, size=3, fill=colors_rep[4]) +
  
  #Annotations
  coord_cartesian(clip = "off") +
  geom_label(aes(x = make_datetime(2018), y = 0.90, label = "Republican Firms"), 
             hjust = -0.1, 
             vjust = 0.0, 
             lineheight = 0.8,
             colour = scol_rep, 
             fill = "white", 
             label.size = NA, 
             family="Helvetica", 
             size = 6) +
  geom_label(aes(x = make_datetime(2018), y = 0.20, label = "Democratic Firms"), 
             hjust = -0.1, 
             vjust = 0.0, 
             lineheight = 0.8,
             colour = scol_dem, 
             fill = "white", 
             label.size = NA, 
             family="Helvetica", 
             size = 6) +
  
  
  #Add bbcstyle
  bbc_style() +
  
  #Manual Scales
  #scale_color_manual("", values=colors_base, labels=occ_labels) +
  scale_shape_manual("", values=c(21, 22, 23, 24), labels=occ_labels) +
  scale_x_datetime(date_labels = "%Y",
                   #Make 1982 - 2018 every 4 years
                   date_breaks = "4 year"
                   # #Make 1980 - 2016 every 4 years
                   # breaks = seq(as.POSIXct("1980-01-01"),
                   #              as.POSIXct("2020-01-01"), "4 years")
  ) +
  scale_y_continuous(limits = y_lim) +
  
  #Xaxis Line
  geom_hline(yintercept = y_int, size = 1, colour="#333333") +
  
  #Plot Margin
  theme(plot.margin=unit(c(1,5,1,1),"cm")) +
  
  #Add axis titles
  theme(axis.title = element_text(size = 18)) +
  xlab("Contribution Cycle") +
  ylab(y_axis_lab) +
  labs(title = plt_title,
       caption = plt_caption) +
  theme(plot.title = element_text(hjust = 0, size = 24)) +
  
  #Adjust Legend Position
  theme(
    legend.spacing.x = unit(2.0, 'mm'),
    legend.text = element_text(size=18)
  ) +
  
  #Add x axis ticks
  theme(
    axis.ticks.x = element_line(colour = "#333333"), 
    axis.ticks.length =  unit(0.26, "cm"),
    axis.text = element_text(size=14, color="#222222")) +
  
  #Override the Legend Fill
  guides(shape = guide_legend(override.aes = list(fill = cols_grey1)))

  finalise_plot(g, plt_caption, outfile, footer=FALSE,  width_pixels=740, height_pixels=450)  
  return(g)
  
}




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
