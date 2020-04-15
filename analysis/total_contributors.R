make_total_contributors_df <- function(input_df){
  require("dplyr")
  require("lazyeval")
  
  #Get Mean by Organization Levels
  
  selvars = list('cycle', 'cid_master', 'occ3')
  groupvars = list('cycle', 'cid_master', 'occ')
  
  df1a <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(occ3)) %>%
    mutate(occ = occ3) %>% 
    group_by_(.dots = groupvars) %>% 
    summarise(totalvar = n())
  
  #Get Mean All Levels
  df1b <-  input_df %>%
    select_(.dots = selvars) %>% 
    filter(!is.na(occ3)) %>%
    mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>%
    mutate(occ = occ4) %>%
    group_by_(.dots = groupvars) %>% 
    summarise(totalvar = n())
  
  df1 <- rbind(df1a, df1b) %>%
    #remove "others" from pre 2004, only all exists before levels can be det.
    mutate(occ = ifelse(occ == "OTHERS" & cycle < 2004, NA, as.character(occ))) %>%
    mutate(occ = factor(occ,
                        levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL"))) %>%
    filter(!is.na(occ))
  
  return(df1)
}


df_in <-  make_total_contributors_df(df_analysis)

df <- df_in %>% 
  group_by(occ, cycle) %>% 
  summarise(meanvar = mean(totalvar, na.rm = T)) %>%
  filter(!is.nan(meanvar)) %>% 
  mutate(avgtotal = meanvar)

g <- ggplot(df, aes(make_datetime(cycle), avgtotal)) +
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
  ylab("Number of Individual Contributors") +
  labs(title = "Average Individual Contributors by Firm",
       caption = "") +
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
    axis.text = element_text(size=10, color="#222222")) +
  
  #Override the Legend Fill
  guides(shape = guide_legend(override.aes = list(fill = colors_base)))

outfile <- wout("avg_indiv_contributors", "by_all_companies")
finalise_plot(g, "", outfile, footer=FALSE)




df <- df_in %>% 
  group_by(occ, cycle) %>% 
  summarise(sumvar = sum(totalvar, na.rm = T)) %>%
  filter(!is.nan(sumvar)) %>% 
  mutate(sumtotal = sumvar)

g <- ggplot(df, aes(make_datetime(cycle), sumtotal)) +
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
  ylab("Number of Individual Contributors") +
  labs(title = "Total Individual Contributors All Firms",
       caption = "") +
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
    axis.text = element_text(size=10, color="#222222")) +
  
  #Override the Legend Fill
  guides(shape = guide_legend(override.aes = list(fill = colors_base)))

outfile <- wout("total_indiv_contributors", "by_all_companies")
finalise_plot(g, "", outfile, footer=FALSE)
