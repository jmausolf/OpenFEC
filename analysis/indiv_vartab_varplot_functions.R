####################################
## Load Contrib SOURCE
####################################

#Set Base Color
pal <- tableau_color_pal(palette = "Color Blind", type = c("regular"), direction = 1)
show_col(pal(4))
colors_base <- pal(4)

show_col(pal(2))
colors_base1 <- pal(2)
tab_blue = "#1770aa"
tab_orange = "#fc7d0b"

occ_labels = c("Executives", "Managers", "Others", "All")


####################################
## Custom Polarization Function
####################################

calc_polarization <- function(x, ...){

  args <- rlang::list2(...)

  #Check for Dim, NA Errors  
  if(is.null(x)){
    return(NA)
  } else {
  }
  
  if(length(x) <= 1){
    return(NA)
  } else {
  }
  
  if (is.data.frame(x)) x <- as.matrix(x) else stopifnot(is.atomic(x))
  x <- na.omit(x)
  
  v <- var(x)
  if(v == 0){
    #Approximation of additional unique element to set if
    #var == 0, to avoid NaN skew and kurtosis
    m = mean(x)
    e = m+(m/100)
    x = c(x, e)
  } else{
  }
  
  s <- timeSeries::colSkewness(x)
  k <- timeSeries::colKurtosis(x)
  
  p <- abs(s)*abs(k)*(1-v)
  
  if(is.element('skewness', args)){
    return(s)
  }
  
  if(is.element('kurtosis', args)){
    return(k)
  } 

  return(p)
  
}


polarization <- function(...){
  args <- rlang::list2(...)
  
  tryCatch({do.call(calc_polarization, args)},
           error=function(error_message) {
             message(error_message)
             return(NA)
           })
  do.call(calc_polarization, args)
}


########################################
#Make PID/PS Var/Sim Measures
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
    summarize(var_pid = var(as.numeric(pid2)),
              skewness_pid = polarization(as.numeric(pid2), "skewness"),
              kurtosis_pid = polarization(as.numeric(pid2), "kurtosis"),
              polarization_raw_pid = polarization(as.numeric(pid2))
    ) 
  
  #Get Variance All Levels
  df1b <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(pid2),
           !is.na(occ3)) %>%
    mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
    mutate(occ = occ4) %>%
    group_by_(.dots = groupvars) %>% 
    summarize(var_pid = var(as.numeric(pid2)),
              skewness_pid = polarization(as.numeric(pid2), "skewness"),
              kurtosis_pid = polarization(as.numeric(pid2), "kurtosis"),
              polarization_raw_pid = polarization(as.numeric(pid2))
    ) 
  
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
    summarize(var_ps = var(as.numeric(partisan_score)),
              skewness_ps = polarization(as.numeric(partisan_score), "skewness"),
              kurtosis_ps = polarization(as.numeric(partisan_score), "kurtosis"),
              polarization_raw_ps = polarization(as.numeric(partisan_score))
    ) 
  
  #Get Variance All Levels
  df1b <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(partisan_score),
           !is.na(occ3)) %>%
    mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
    mutate(occ = occ4) %>%
    group_by_(.dots = groupvars) %>% 
    summarize(var_ps = var(as.numeric(partisan_score)),
              skewness_ps = polarization(as.numeric(partisan_score), "skewness"),
              kurtosis_ps = polarization(as.numeric(partisan_score), "kurtosis"),
              polarization_raw_ps = polarization(as.numeric(partisan_score))
    ) 
  
  df1 <- rbind(df1a, df1b) %>%
    #remove "others" from pre 2004, only all exists before levels can be det.
    mutate(occ = ifelse(occ == "OTHERS" & cycle < 2004, NA, as.character(occ))) %>%
    mutate(occ = factor(occ,
                        levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL"))) %>%
    filter(!is.na(occ))
  
  return(df1)
}


########################################
#Var/Sim Tables Functions
########################################

# make_partisan_hist_df <- function(input_df, company_var, party_var){
#   require("dplyr")
#   require("lazyeval")
  
#   #Get Variance by Organization Levels
  
#   selvars = list('cycle', company_var, 'partisan_score', 'occ3')
#   groupvars = list('cycle', company_var, 'occ')
  
#   df1a <-  input_df %>%
#     select_(.dots = selvars) %>% 
#     filter(!is.na(partisan_score),
#            !is.na(occ3)) %>%
#     mutate(occ = occ3) %>% 
#     group_by_(.dots = groupvars) 

  
#   #Get Variance All Levels
#   df1b <-  input_df %>%
#     select_(.dots = selvars) %>% 
#     filter(!is.na(partisan_score),
#            !is.na(occ3)) %>%
#     mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
#     mutate(occ = occ4) %>%
#     group_by_(.dots = groupvars) 

  
#   df1 <- rbind(df1a, df1b) %>%
#     #remove "others" from pre 2004, only all exists before levels can be det.
#     mutate(occ = ifelse(occ == "OTHERS" & cycle < 2004, NA, as.character(occ))) %>%
#     mutate(occ = factor(occ,
#                         levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL"))) %>%
#     filter(!is.na(occ))
  
#   return(df1)
# }



##VARIANCE TABLE FUNCTIONS
var_sum_table <- function(df, 
                          filepath="output/vartable1.tex", 
                          tabtitle="title") {
  vartab <- df %>% 
    group_by(occ) %>% 
    summarise(meanvar = mean(var_pid, na.rm = T),
              medvar = median(var_pid, na.rm = T),
              sdvar = sd(var_pid, na.rm = T)
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
    summarise(meanvar = mean(var_pid, na.rm = T)) %>%
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



########################################
# Var/Sim Graph Functions
########################################

##VARIANCE GRAPH FUNCTIONS

##----------------------------  
## Base Graph - Pre HCA
make_polar_graph_base_pid <- function(df_in, key, plt_type="cid_master", plt_title="", plt_caption=""){

  key = sym(key)

  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df <- df_in %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(!!key, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = meanvar)
  
  g <- ggplot(df, aes(make_datetime(cycle), polarization)) +
  geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
  geom_line(aes(color=occ), alpha=0.9) +
  
  #Add Point to Add the Shape by Occ
  geom_point(aes(shape=occ), alpha=1, size=3) +

  #Fill Each Occ Shape / Get Outline Independently
  geom_point(data = df %>% filter(occ == "CSUITE"), shape=21, alpha=1,
             pch=21, size=3, fill=colors_base[1]) +
  geom_point(data = df %>% filter(occ == "MANAGEMENT"), shape=22, alpha=1,
             pch=21, size=3, fill=colors_base[2]) +
  geom_point(data = df %>% filter(occ == "OTHERS"), shape=23, alpha=1,
             pch=21, size=3, fill=colors_base[3]) +
  geom_point(data = df %>% filter(occ == "ALL"), shape=24, alpha=1,
             pch=21, size=3, fill=colors_base[4]) +
  
    #Add bbcstyle
  bbc_style() +
  
  #Manual Scales
  scale_color_manual("", values=colors_base, labels=occ_labels) +
  scale_shape_manual("", values=c(21, 22, 23, 24), labels=occ_labels) +
  scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
  
  #Xaxis Line
  geom_hline(yintercept = 0.0, size = 1, colour="#333333") +
  
  #Add axis titles
  theme(axis.title = element_text(size = 18)) +
  xlab("Contribution Cycle") +
  ylab("Partisan Polarization [0, 1]") +
  labs(title = plt_title,
       caption = plt_caption) +
  theme(plot.title = element_text(hjust = 0.5)) +
  
  #Adjust Legend Position
  theme(
    legend.justification='left',
    legend.direction='vertical',
    legend.position=c(0.0,.9)
  ) +
  
  #Add x axis ticks
  theme(
    axis.ticks.x = element_line(colour = "#333333"), 
    axis.ticks.length =  unit(0.26, "cm"),
    axis.text = element_text(size=10, color="#222222")) +

  #Override the Legend Fill
  guides(shape = guide_legend(override.aes = list(fill = colors_base)))
  
  finalise_plot(g, plt_caption, outfile, footer=FALSE)
  return(g)
  
}



make_var_graph_base_pid <- function(df, key, plt_type="cid_master", plt_title="", plt_caption=""){

  key = sym(key)
  #require("dplyr")
  #require("lazyeval")
  
  #Get Variance by Organization Levels
  
  #keyvar = list(key)

  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(!!key, na.rm = T)) %>%
    #summarise(meanvar = mean(key, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +
    
    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_base) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0.75, 0.97)) +
    geom_hline(yintercept = 0.75, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Party~ID)})) +
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


make_var_graph_base_ps <- function(df, plt_type="cid_master", plt_title="", plt_caption=""){

  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  #plt_title = "Variance of Within-Company Individual Contributions by Occupation and Election Cycle"
    
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(var_ps, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_base) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0.2, 1.0)) +
    geom_hline(yintercept = 0.2, size = 1, colour="#333333") +

    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Partisan~Score)})) +
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

make_var_graph_dem_pid <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(var_pid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#2129B0", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_dem) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0.75, 0.97)) +
    geom_hline(yintercept = 0.75, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Party~ID)})) +
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


make_var_graph_dem_ps <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(var_ps, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#2129B0", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_dem) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0.2, 1.0)) +
    geom_hline(yintercept = 0.2, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Partisan~Score)})) +
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

make_var_graph_rep_pid <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(var_pid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#BF1200", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_rep) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0.75, 0.97)) +
    geom_hline(yintercept = 0.75, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Party~ID)})) +
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


make_var_graph_rep_ps <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(var_ps, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#BF1200", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_rep) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0.2, 1.0)) +
    geom_hline(yintercept = 0.2, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Partisan~Score)})) +
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

make_var_graph_oth_pid <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(var_pid, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_neutral) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0.75, 0.97)) +
    geom_hline(yintercept = 0.75, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Party~ID)})) +
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


make_var_graph_oth_ps <- function(df, plt_type="cid_master", plt_caption="", plt_title=""){
  
  out_by = paste("by_all_companies", plt_type, sep = "_")
  outfile <- wout("indiv_plt_partisan_variance_occ", out_by)
  
  df_var_cycle_graph <- df %>% 
    group_by(occ, cycle) %>% 
    summarise(meanvar = mean(var_ps, na.rm = T)) %>%
    filter(!is.nan(meanvar)) %>% 
    mutate(polarization = 1-meanvar)
  
  g <- ggplot(df_var_cycle_graph, aes(make_datetime(cycle), polarization)) +
    geom_smooth(color="#3A084A", alpha=0.15, size=0.5) +
    geom_line(aes(color=occ), alpha=0.9) +
    geom_point(aes(shape=occ), alpha=1) +

    #Add bbcstyle
    bbc_style() +
    
    scale_color_manual(values=colors_neutral) +
    scale_shape_manual(values=c(10, 1, 2, 6)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
    scale_y_continuous(limits = c(0.2, 1.0)) +
    geom_hline(yintercept = 0.2, size = 1, colour="#333333") +
    
    #Add axis titles
    theme(axis.title = element_text(size = 18)) +
    xlab("Contribution Cycle") +
    ylab(expression(Partisan~Polarization=={1-VAR(Partisan~Score)})) +
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

