#Load Libraries
library(tidyverse)
library(stargazer)
library(knitr)
library(pastecs)
library(forcats)
library(stringr)
library(lubridate)
library(scales)
library(DBI)



##Load Data
con <- dbConnect(RSQLite::SQLite(), "../fec_download/openFEC.db")
fec <- dbGetQuery(con, "SELECT * FROM schedule_a_cleaned")  %>% 
        mutate(sub_id = as.character(sub_id))


source("assemble_plots.R")

##Make directory
system('mkdir -p images')

wout <- function(plt_type, cid){
  outfile <- paste0("images/", plt_type, "_", str_replace_all(tolower(cid), " ", "_"), ".png")
  return(outfile)
}

################################################
## Clean data
################################################

#All Contributions, All CID
dfm <- fec %>% 
  #filter(cid!="Berkshire Hathaway") %>% 
  #filter(cid!="Home Depot") %>% 
  # mutate(pid = fct_collapse(party_id,
  #                           "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
  mutate(pid = fct_collapse(party_id,
                             "NA-ERROR-UNKNOWN" = c("UNK_OTHER", "UNK", "GRE_UNK_OTHER")),
         pid5 = fct_lump(party_id, n=4),
         pid4 = fct_lump(party_id, n=3),
         pid3 = fct_lump(party_id, n=2)) %>% 
  #mutate(pid3 = if_else(pid3!="Other", pid3, as.factor("OTHER"), missing = NULL)) %>%
  mutate(pid2 = if_else(pid3!="Other", pid3, NULL, missing = NULL)) %>% 
  #mutate(pid2 = if_else(pid3!="UNK_OTHER", pid3, NULL, missing = NULL)) %>% 
  # mutate(cid = factor(cid, 
  #                     levels = c("Amazon", "Apple", "Microsoft",
  #                                "Boeing", "Ford Motor", "General Motors",
  #                                "Chevron", "Exxon", "Marathon Oil",
  #                                "Citigroup", "Goldman Sachs", "Wells Fargo",
  #                                "CVS", "Kroger", "Walmart"
  #                     ))) %>% 
  mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
  mutate(cycle = as.numeric(cmte_cycle))
  # %>% 
  # mutate(lncval = log(as.numeric(contributor_transaction_amt)+1)) 


##Clean Occupations
#occupations <-  as.data.frame(table(dfm$contributor_occupation))
dfocc <- dfm %>% 
  mutate(occlevels = 'OTHERS') %>% 
  mutate(occlevels = if_else(executive == "True", "CSUITE", occlevels),
         occlevels = if_else(director == "True", "DIRECTOR", occlevels),
         occlevels = if_else(manager == "True", "MANAGER", occlevels)) %>% 
  mutate(occ3 = fct_collapse(occlevels,
                             "MANAGEMENT" = c("MANAGER", "DIRECTOR")))


dfocc3 <- dfocc %>% 
  select(cycle, pid3, pid2, cid, occlevels, occ3) %>% 
  filter(!is.na(pid2),
         !is.na(occlevels),
         cycle >= 2004) %>% 
  mutate(cycle = as.numeric(cycle))


##GRAPH
#PARTISAN LEANING OCCLEVELS
#ALL COMPANIES
outfile <- wout("plt_partisan_occ", "by_all_companies")
#lims <- c(as.POSIXct(as.Date("2001/01/02")), NA)
lims <- c(as.POSIXct(as.Date("2003/01/02")), NA)
p1 <- ggplot(dfocc3) +
  geom_bar(aes(make_datetime(cycle), fill = pid2), alpha=0.95, position = "fill") +
  facet_grid(cid~occ3) +
  #scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
  scale_x_datetime(date_labels = "%Y") +
  scale_fill_manual(values=c("#2129B0", "#BF1200")) +
  xlab("Contribution Cycle") +
  ylab("Partisanship of Individual Contributions") +
  ggtitle(paste("Contributions by Occupational Hierarchy and Company")) +
  theme(legend.position="bottom") +
  theme(legend.title=element_blank()) + 
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(strip.text.y = element_text(size = 7))
ggsave(outfile, width = 10, height = 14)


#PARTISAN LEANING OCCLEVELS
#ALL COMPANIES
outfile <- wout("plt_partisan_occ", "all_companies")
lims <- c(as.POSIXct(as.Date("2001/01/02")), NA)
ggplot(dfocc3) +
  geom_bar(aes(make_datetime(cycle), fill = pid2), alpha=0.95, position = "fill") +
  facet_grid(.~occ3) +
  #scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
  scale_fill_manual(values=c("#2129B0", "#BF1200")) +
  xlab("Contribution Cycle") +
  ylab("Partisanship of Individual Contributions") +
  ggtitle(paste("Contributions by Occupational Hierarchy: All Companies")) +
  theme(legend.position="bottom") +
  theme(legend.title=element_blank()) + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave(outfile)

# Plot
ggplot(df2) +
  geom_bar(aes(x = occlevels, fill = pid2), position = "fill")

ggplot(df2, aes(make_datetime(cycle), occlevels, fill = pid2), position = "fill") +
  geom_bar(position = position_dodge(width=0.5), stat="identity") +
  #geom_text(aes(y = pos, label = label), size = 2) +
  coord_flip()


# All Companies, By Party
df <- dfm %>% 
  select(cycle, pid3, pid2, cid, occ) %>% 
  group_by(cycle, cid, pid3) %>% 
  mutate(contrib_count = n()) %>% 
  unique()


lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
ggplot(dfm, aes()) +
  geom_bar(aes(pid2)) +
  facet_wrap(~cycle) 


ggplot(dfm, aes()) +
  geom_bar(aes(pid5)) +
  facet_wrap(~cycle) 


# All Companies, By Party
dfb <- dfm %>% 
  select(cycle, pid3, pid2, cid) %>% 
  group_by(cycle, cid, pid3) %>% 
  mutate(contrib_count = n()) %>% 
  unique()


df1 <- dfb %>%
  filter(as.integer(pid3) == 1)
df2 <- dfb %>%
  filter(as.integer(pid3) == 2)
# df3 <- dfb %>%
#   filter(as.integer(pid3) == 3)

outfile <- wout("plt_parties", "all_companies")
lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
a1 <- ggplot(NULL, aes(make_datetime(cycle), contrib_count, group = cid)) +
  geom_line(data = df1, aes(color=pid3)) + 
  geom_line(data = df2, aes(color=pid3)) + 
  geom_point(data = df1, aes(shape=cid), alpha=0.5) +
  geom_point(data = df2, aes(shape=cid), alpha=0.5) +
  scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
  scale_y_log10(labels = comma) +
  scale_color_manual(values=c("#2129B0", "#BF1200", "#360033")) +
  scale_shape_manual(values=c(
    0, 0, 0, 1, 
    1, 1, 2, 2, 
    2, 4, 4, 4, 
    6, 6, 6, 6)) +
  xlab("Contribution Cycle") +
  ylab("Number of Schedule A Contributions") +
  ggtitle(paste("Contributions by Party: All Companies")) +
  theme(legend.title=element_blank()) + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave(outfile)


#All Contributions, All CID
df <-  dfm %>%
  select(cycle, cid) %>% 
  group_by(cycle, cid) %>% 
  mutate(contrib_count = n()) %>% 
  unique()
  
outfile <- wout("plt_contrib", "all_companies")
lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
a2 <- ggplot(df, aes(make_datetime(cycle), contrib_count)) +
  geom_line(aes(color=cid), alpha=0.5) +
  geom_point(aes(shape=cid), alpha=0.5) +
  geom_smooth(color='darkblue', aes(fill="Average")) +
  scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
  scale_y_log10(labels = comma) +
  scale_color_manual(values=c(
    "#F5A200", "#DB9100", "#B57800", 
    "#F50094", "#81004E", "#4F0030", 
    "#BF1220", "#BF1400", "#BF3200", 
    "#068100", "#033600", "#044F00", 
    "#007581", "#00C7DB", "#00DFF5")) +
  scale_shape_manual(values=c(
    0, 0, 0, 1, 
    1, 1, 2, 2, 
    2, 4, 4, 4, 
    6, 6, 6, 6)) +
  scale_fill_manual(values = c(Average="#c6c6c6")) +
  xlab("Contribution Cycle") +
  ylab("Number of Schedule A Contributions") +
  ggtitle(paste("Total Individual Contributions by Company")) +
  guides(shape = guide_legend(override.aes = list(size = 5))) +
  theme(legend.title=element_blank()) + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave(outfile)


#Contrib variance
df <-  dfm %>%
  select(cycle, cid, pid2) %>% 
  filter(!is.na(pid2)) %>% 
  group_by(cycle, cid) %>% 
  summarize(varpid = var(as.numeric(pid2)))

# Perhaps make both
# df <-  dfm %>%
#   select(cycle, cid, pid4) %>% 
#   filter(!is.na(pid4)) %>% 
#   group_by(cycle, cid) %>% 
#   summarize(varpid = var(as.numeric(pid4)))

outfile <- wout("plt_variance", "all_companies")
lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
a3 <- ggplot(df, aes(make_datetime(cycle), varpid)) +
  geom_line(aes(color=cid), alpha=0.5) +
  geom_point(aes(shape=cid), alpha=0.5) +
  geom_smooth(color='darkblue', aes(fill="Average")) +
  scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
  #scale_y_log10(labels = comma) +
  scale_color_manual(values=c(
    "#F5A200", "#DB9100", "#B57800", 
    "#F50094", "#81004E", "#4F0030", 
    "#BF1220", "#BF1400", "#BF3200", 
    "#068100", "#033600", "#044F00", 
    "#007581", "#00C7DB", "#00DFF5")) +
  scale_shape_manual(values=c(
    0, 0, 0, 1, 
    1, 1, 2, 2, 
    2, 4, 4, 4, 
    6, 6, 6, 6)) +
  scale_fill_manual(values = c(Average="#c6c6c6")) +
  xlab("Contribution Cycle") +
  ylab("Variance of Party Contributions") +
  ggtitle(paste("Variance of Party Contributions by Company")) +
  guides(shape = guide_legend(override.aes = list(size = 5))) +
  theme(legend.title=element_blank()) + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave(outfile)

#Variance Occupations
df <-  dfocc3 %>%
  select(cycle, cid, pid2, occ3) %>% 
  filter(!is.na(pid2),
         !is.na(occ3)) %>% 
  group_by(cycle, cid, occ3) %>% 
  summarize(varpid = var(as.numeric(pid2)))

df1 <- df %>% 
  filter(occ3=="CSUITE") 

df2 <- df %>% 
  filter(occ3=="MANAGEMENT") 

df3 <-  df %>%
  filter(occ3=="OTHERS")

##VARIANCE PLOT
outfile <- wout("plt_variance_occ", "all_companies")
lims <- c(as.POSIXct(as.Date("2001/01/02")), NA)
ggplot(df, aes(make_datetime(cycle), varpid, color=occ3)) +
  stat_smooth(se=FALSE, method = "lm") +
  #geom_smooth(se=FALSE) +
  #geom_point(alpha = 0.3) +
  scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
  scale_color_manual(values=c("#F2B809", "#03275A", "#1A7DD7")) +
  facet_wrap(~cid, nrow = 5) +
  xlab("Contribution Cycle") +
  ylab("Variance of Party Contributions") +
  labs(colour = "Organizational Hierarchy: ") +
  ggtitle(paste("Variance of Party Contributions by Organizational Hierarchy and Company")) +
  guides(shape = guide_legend(override.aes = list(size = 5))) +
  theme(legend.position="bottom") +
  theme(plot.title = element_text(hjust = 0.5))
ggsave(outfile, width = 10, height = 14)

#Variance Occupations
df <-  dfocc3 %>%
  select(cycle, cid, pid2, occ3) %>% 
  filter(!is.na(pid2),
         !is.na(occ3)) %>% 
  group_by(cycle, cid, occ3) %>% 
  summarize(varpid = var(as.numeric(pid2)))

#All individuals
df <-  dfg %>%
  select(cycle, cid, contributor_name) %>% 
  group_by(cycle, cid, contributor_name) %>% 
  mutate(contrib_count = n()) %>% 
  unique()


df <- dfm %>% 
  # filter(cid=="Goldman Sachs") %>% 
  filter(!is.na(pid2))

##SCATTER PLOT
outfile <- wout("plt_scatter_avg", "all_companies")
lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
ggplot(df, aes(contribution_receipt_date, contribution_receipt_amount)) +
  #geom_line(aes(color=cid), alpha=0.5) +
  geom_jitter(aes(color=pid2), alpha=0.2) +
  geom_smooth(aes(color=pid2)) +
  scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
  scale_y_log10(labels = comma) +
  # scale_color_manual(values=c(
  #   "#2129B0", "#BF1200", "#F5A200", 
  #   "#F50094", "#4F0030", "#BF1220", 
  #   "#068100", "#BF1400", "#BF3200", 
  #   "#00DFF5", "#033600", "#044F00", 
  #   "#007581", "#00C7DB", "#00DFF5", "#360033")) +
  # scale_shape_manual(values=c(
  #   0, 0, 0, 1, 
  #   1, 1, 2, 2, 
  #   2, 4, 4, 4, 
  #   6, 6, 6, 6)) +
  # scale_fill_manual(values = c(Average="#c6c6c6")) +
  scale_color_manual(values=c("#2129B0", "#BF1200", "#360033")) +
  xlab("Contribution Date") +
  ylab("Contribution Receipt Amount in USD") +
  ggtitle(paste("Vale of Individual Contributions by Party")) +
  guides(color = guide_legend(override.aes = list(size = 5))) +
  theme(legend.title=element_blank()) + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave(outfile, width = 8, height = 8)


################################################
## Company DF's - 2 PARTY
################################################

df_plt_a <- function(company){
  df <- dfm %>%
    filter(cid == company) %>%
    filter(!is.na(pid2)) %>% 
    mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
    mutate(lncval = log(contribution_receipt_amount+1))
  return(df)
}


df_plt_b <- function(company){
  df <- dfm %>% 
    filter(cid == company) %>%
    filter(!is.na(pid2)) %>% 
    mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
    mutate(lncval = log(contribution_receipt_amount+1)) %>% 
    group_by(contribution_receipt_date, pid2) %>% 
    mutate(contrib_count = n())
  return(df)
}

df_plt_c <- function(company){
  df <- dfm %>% 
    filter(cid == company) %>%
    filter(!is.na(pid2)) %>% 
    #mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
    #mutate(lncval = log(contribution_receipt_amount+1)) %>% 
    group_by(cycle, pid2) %>% 
    mutate(contrib_count = n())
  return(df)
}


df_plt_d <- function(company){
  df <- dfm %>%
    filter(cid == company) %>% 
    select(cycle, cid, pid2) %>% 
    filter(!is.na(pid2)) %>% 
    #mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
    #mutate(lncval = log(contribution_receipt_amount+1)) %>% 
    group_by(cycle, cid) %>% 
    summarize(varpid2 = var(as.numeric(pid2))) 
  return(df)
}


################################################
## Company DF's - UNKNOWN
################################################

df_plt_a_uk <- function(company){
  df <- dfm %>%
    filter(cid == company) %>%
    # filter(cid == "Marathon Oil") %>%
    filter(!is.na(pid4)) %>% 
    mutate(piduk = fct_collapse(pid4, UNKNOWN_PARTY = c("UNKNOWN", "Other")))
  return(df)
}


df_plt_b_uk <- function(company){
  df <- dfm %>% 
    filter(cid == company) %>%
    # filter(cid == "Marathon Oil") %>%
    filter(!is.na(pid4)) %>%
    mutate(piduk = fct_collapse(pid4, UNKNOWN_PARTY = c("UNKNOWN", "Other"))) %>% 
    group_by(contribution_receipt_date, piduk) %>% 
    mutate(contrib_count = n())
  return(df)
}


df_plt_c_uk <- function(company){
  df <- dfm %>% 
    filter(cid == company) %>%
    # filter(cid == "Marathon Oil") %>%
    filter(!is.na(pid4)) %>%
    mutate(piduk = fct_collapse(pid4, UNKNOWN_PARTY = c("UNKNOWN", "Other"))) %>% 
    group_by(cycle, piduk) %>% 
    mutate(contrib_count = n())
  return(df)
}

df_plt_d_uk <- function(company){
  df <- dfm %>%
    filter(cid == company) %>%
    # filter(cid == "Marathon Oil") %>%
    select(cycle, cid, pid4) %>% 
    filter(!is.na(pid4)) %>%
    mutate(piduk = fct_collapse(pid4, UNKNOWN_PARTY = c("UNKNOWN", "Other"))) %>% 
    group_by(cycle, cid) %>% 
    summarize(varpiduk = var(as.numeric(piduk))) 
  return(df)
}


################################################
## Make Graphs 2 PARTY
################################################



## Plot A
## PLOT TS-PARTY - All Individual Contributions (Contribution Level)
plt_a <- function(df){
  lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
  cid <- as.character(df$cid[1])
  outfile <- wout("plt_a", cid)
  g <- ggplot(df, aes(contribution_receipt_date, contribution_receipt_amount, color=pid2)) +
    geom_smooth() + 
    scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
    scale_y_continuous(labels = comma) +
    #scale_color_manual(values=c("#dem", "#rep")) +
    #scale_color_manual(values=c("#262F7F", "#7F0000")) +
    scale_color_manual(values=c("#2129B0", "#BF1200")) +
    xlab("Contribution Date") +
    ylab("Contribution Receipt Amount in USD") +
    ggtitle(paste("Contribution Value by Party:", cid, sep=" ")) +
    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  #save
  ggsave(outfile)
  
  #return
  return(g)
}

## Plot B
## PLOT TS-PARTY - All Individual Contributions (Contribution Level)
plt_b <- function(df){
  lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
  cid <- as.character(df$cid[1])
  outfile <- wout("plt_b", cid)
  g <- ggplot(df, aes(contribution_receipt_date, contrib_count, color=pid2, shape=pid2)) +
    geom_point(alpha=0.25) +
    geom_smooth() + 
    scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
    scale_y_continuous(labels = comma) +
    scale_color_manual(values=c("#2129B0", "#BF1200")) +
    scale_shape_manual(values = c(3, 1)) +
    xlab("Contribution Date") +
    ylab("Number of Schedule A Contributions") +
    ggtitle(paste("Contributions by Party:", cid, sep=" ")) +
    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  #save
  ggsave(outfile)
  
  #return
  return(g)
}

options(scipen=10000)

## PLOT C - Cycles by Party
plt_c <- function(df){
  lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
  cid <- as.character(df$cid[1])
  outfile <- wout("plt_c", cid)
  g <- ggplot(df, aes(make_datetime(cycle), contrib_count, color=pid2, shape=pid2)) +
    geom_point(alpha=0.25) +
    geom_line() + 
    scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
    scale_y_continuous(labels = comma) +
    #scale_y_log10(labels = comma) +
    scale_color_manual(values=c("#2129B0", "#BF1200")) +
    scale_shape_manual(values = c(3, 1)) +
    xlab("Contribution Cycle") +
    ylab("Number of Schedule A Contributions") +
    ggtitle(paste("Contributions by Party:", cid, sep=" ")) +
    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  #save
  ggsave(outfile)
  
  #return
  return(g)
}

## PLOT C - Cycles by Party
plt_clog <- function(df){
  lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
  cid <- as.character(df$cid[1])
  outfile <- wout("plt_clog", cid)
  g <- ggplot(df, aes(make_datetime(cycle), contrib_count, color=pid2, shape=pid2)) +
    geom_point(alpha=0.25) +
    geom_line() + 
    scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
    #scale_y_continuous(labels = comma) +
    scale_y_log10(labels = comma) +
    scale_color_manual(values=c("#2129B0", "#BF1200")) +
    scale_shape_manual(values = c(3, 1)) +
    xlab("Contribution Cycle") +
    ylab("Number of Schedule A Contributions") +
    ggtitle(paste("Contributions by Party:", cid, sep=" ")) +
    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  #save
  ggsave(outfile)
  
  #return
  return(g)
}

plt_d <- function(df){
  lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
  cid <- as.character(df$cid[1])
  outfile <- wout("plt_d", cid)
  g <- ggplot(df) +
    #geom_point(alpha=0.25) +
    geom_line(aes(make_datetime(cycle), varpid2)) +
    #geom_line(aes(make_datetime(cycle), varpid5)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
    scale_y_continuous(labels = comma) +
    scale_color_manual(values=c("#2129B0", "#BF1200")) +
    scale_shape_manual(values = c(3, 1)) +
    scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9"), 
                      name="Experimental\nCondition",
                      breaks=c("ctrl", "trt1", "trt2"),
                      labels=c("Control", "Treatment 1", "Treatment 2")) +
    xlab("Contribution Cycle") +
    ylab("Variance of Party Contributions") +
    ggtitle(paste("Partisan Variance:", cid, sep=" ")) +
    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) +
    theme(plot.title = element_text(hjust = 0.5))

  #save
  ggsave(outfile)

  #return
  return(g)
}



################################################
## Make Graphs UNKNOWN PARTY
################################################


## Plot A
## PLOT TS-PARTY - All Individual Contributions (Contribution Level)
plt_a_uk <- function(df){
  lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
  cid <- as.character(df$cid[1])
  outfile <- wout("plt_a", cid)
  g <- ggplot(df, aes(contribution_receipt_date, contribution_receipt_amount, color=piduk)) +
    geom_smooth() + 
    scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
    scale_y_continuous(labels = comma) +
    #scale_color_manual(values=c("#dem", "#rep")) +
    #scale_color_manual(values=c("#262F7F", "#7F0000")) +
    scale_color_manual(values=c("#2129B0", "#BF1200", "#360033")) +
    xlab("Contribution Date") +
    ylab("Contribution Receipt Amount in USD") +
    ggtitle(paste("Contribution Value by Party:", cid, sep=" ")) +
    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  #save
  ggsave(outfile)
  
  #return
  return(g)
}

## Plot B
## PLOT TS-PARTY - All Individual Contributions (Contribution Level)
plt_b_uk <- function(df){
  lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
  cid <- as.character(df$cid[1])
  outfile <- wout("plt_b", cid)
  g <- ggplot(df, aes(contribution_receipt_date, contrib_count, color=piduk, shape=piduk)) +
    geom_point(alpha=0.25) +
    geom_smooth() + 
    scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
    scale_y_continuous(labels = comma) +
    scale_color_manual(values=c("#2129B0", "#BF1200", "#360033")) +
    scale_shape_manual(values = c(3, 1, 0)) +
    xlab("Contribution Date") +
    ylab("Number of Schedule A Contributions") +
    ggtitle(paste("Contributions by Party:", cid, sep=" ")) +
    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  #save
  ggsave(outfile)
  
  #return
  return(g)
}

options(scipen=10000)

## PLOT C - Cycles by Party
plt_c_uk <- function(df){
  lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
  cid <- as.character(df$cid[1])
  outfile <- wout("plt_c", cid)
  g <- ggplot(df, aes(make_datetime(cycle), contrib_count, color=piduk, shape=piduk)) +
    geom_point(alpha=0.25) +
    geom_line() + 
    scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
    scale_y_continuous(labels = comma) +
    #scale_y_log10(labels = comma) +
    scale_color_manual(values=c("#2129B0", "#BF1200", "#360033")) +
    scale_shape_manual(values = c(3, 1, 0)) +
    xlab("Contribution Cycle") +
    ylab("Number of Schedule A Contributions") +
    ggtitle(paste("Contributions by Party:", cid, sep=" ")) +
    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  #save
  ggsave(outfile)
  
  #return
  return(g)
}

## PLOT C - Cycles by Party
plt_clog_uk <- function(df){
  lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
  cid <- as.character(df$cid[1])
  outfile <- wout("plt_clog", cid)
  g <- ggplot(df, aes(make_datetime(cycle), contrib_count, color=piduk, shape=piduk)) +
    geom_point(alpha=0.25) +
    geom_line() + 
    scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
    #scale_y_continuous(labels = comma) +
    scale_y_log10(labels = comma) +
    scale_color_manual(values=c("#2129B0", "#BF1200", "#360033")) +
    scale_shape_manual(values = c(3, 1, 0)) +
    xlab("Contribution Cycle") +
    ylab("Number of Schedule A Contributions") +
    ggtitle(paste("Contributions by Party:", cid, sep=" ")) +
    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  #save
  ggsave(outfile)
  
  #return
  return(g)
}

plt_d_uk <- function(df){
  lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
  cid <- as.character(df$cid[1])
  outfile <- wout("plt_d", cid)
  g <- ggplot(df) +
    #geom_point(alpha=0.25) +
    geom_line(aes(make_datetime(cycle), varpiduk)) +
    #geom_line(aes(make_datetime(cycle), varpid5)) +
    scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
    scale_y_continuous(labels = comma) +
    scale_color_manual(values=c("#2129B0", "#BF1200", "#360033")) +
    scale_shape_manual(values = c(3, 1)) +
    scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9"), 
                      name="Experimental\nCondition",
                      breaks=c("ctrl", "trt1", "trt2"),
                      labels=c("Control", "Treatment 1", "Treatment 2")) +
    xlab("Contribution Cycle") +
    ylab("Variance of Party Contributions") +
    ggtitle(paste("Partisan Variance:", cid, sep=" ")) +
    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) +
    theme(plot.title = element_text(hjust = 0.5))
  
  #save
  ggsave(outfile)
  
  #return
  return(g)
}


################################################
## Run
################################################




mp <- function(cid){
  outfile <- paste0("output/", "mp_", str_replace_all(tolower(cid), " ", "_"), ".png")
  png(outfile, 
      width = 8000, height = 3000,
      pointsize = 8, res = 600)
  multiplot(g1, g3, g4, cols=3)
  dev.off()
}

mp_uk <- function(cid){
  outfile <- paste0("output/", "mp_uk_", str_replace_all(tolower(cid), " ", "_"), ".png")
  png(outfile, 
      width = 8000, height = 3000,
      pointsize = 8, res = 600)
  multiplot(g1, g3, g4, cols=3)
  dev.off()
}


mpa <- function(cid){
  outfile <- paste0("output/", "mpa_", str_replace_all(tolower(cid), " ", "_"), ".png")
  png(outfile, 
      width = 10000, height = 3000,
      pointsize = 8, res = 600)
  #multiplot(g1, g3, g4, cols=3)
  multiplot(a1, a2, a3, cols=3)
  dev.off()
}


# companies <- c("Exxon", "Microsoft", "General Motors", "Citigroup", "Goldman Sachs", "Walmart", "Marathon Oil", "Apple", "Berkshire Hathaway", "Amazon", "Boeing", "Home Depot", "Ford Motor", "Kroger", "Chevron", "Wells Fargo", "CVS")

companies <- c("Exxon", "Microsoft", "General Motors", "Citigroup", "Goldman Sachs", "Walmart", "Marathon Oil", "Apple", "Amazon", "Boeing", "Ford Motor", "Kroger", "Chevron", "Wells Fargo", "CVS")

#companies <- c("Exxon", "Marathon Oil", "Chevron")
#companies <- c("Goldman Sachs")
#make three graph plots

#MAJOR 2-PARTY GRAPHS
for (cid in companies){
  g1 <- plt_a(df_plt_a(cid))
  g3 <- plt_c(df_plt_c(cid))
  g4 <- plt_d(df_plt_d(cid))
  
  g5 <- plt_clog(df_plt_c(cid))

  mp(cid)

}

#UNKNOWN 3-PARTY GRAPHS
for (cid in companies){
  g1 <- plt_a_uk(df_plt_a_uk(cid))
  g3 <- plt_c_uk(df_plt_c_uk(cid))
  g4 <- plt_d_uk(df_plt_d_uk(cid))
  
  g5 <- plt_clog_uk(df_plt_c_uk(cid))
  
  mp_uk(cid)
  
}


#group graphs
mpa("all companies")





