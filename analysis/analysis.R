#Load Libraries
library(tidyverse)
library(stargazer)
library(knitr)
library(pastecs)
library(forcats)
library(stringr)
library(lubridate)
library(scales)

source("assemble_plots.R")

##Load Data
#fec <- read_csv("Exxon_Mobile__merged_deduped_ANALYSIS_cleaned.csv")
#fec <- read_csv("Goldman_Sachs__schedule_a__merged_ANALYSIS_cleaned.csv")
#fec <- read_csv("ANALYSIS_cleaned__merged_MASTER.csv")
fec <- read_csv("ANALYSIS_cleaned_deduped__merged_MASTER.csv")
#fec <- read_csv("ANALYSIS_cleaned__merged_MASTER_v2.csv")
# fec <- read_csv("Boeing__schedule_a__merged_ANALYSIS.csv")
# fec <- read_csv("Boeing__merged_deduped_ANALYSIS_cleaned.csv")

##Make directory
system('mkdir -p images')


################################################
## Clean data
################################################


#Work on Base Cleaning
dfb <- fec %>% 
  #filter(cid == company) %>%
  #filter(cid == "Goldman Sachs") %>%
  select(party_id, cycle, cid) %>% 
  mutate(pid = fct_collapse(party_id,
                            "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
         pid5 = fct_lump(pid, n=5)) %>% 
  mutate(pid3 = fct_lump(pid, n=3)) %>% 
  filter(pid3 != "Other") %>% 
  select(cycle, pid5, pid3, cid) %>% 
  #mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
  #mutate(lncval = log(contribution_receipt_amount+1)) %>% 
  group_by(cycle, cid, pid3) %>% 
  mutate(contrib_count = n()) %>% 
  unique()

df1 <- dfb %>%
  filter(as.integer(pid3) == 1)
df2 <- dfb %>%
  filter(as.integer(pid3) == 2)
df3 <- dfb %>%
  filter(as.integer(pid3) == 3)

lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
ggplot(NULL, aes(make_datetime(cycle), contrib_count, group = cid)) +
  #geom_point(alpha=0.25) +
  geom_line(data = df1, aes(color=pid3)) + 
  #geom_line(data = df2, aes(color=pid3)) + 
  geom_line(data = df3, aes(color=pid3)) + 
  geom_smooth(data = dfb, aes(color=pid3)) +
  scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
  #scale_y_continuous(labels = comma) +
  #scale_y_log10(labels = comma) +
  #scale_color_manual(values=c("#2129B0", "#BF1200")) +
  #scale_shape_manual(values = c(3, 1)) +
  xlab("Contribution Cycle") +
  ylab("Number of Schedule A Contributions") +
  ggtitle(paste("Contributions by Party:", cid, sep=" ")) +
  theme(legend.position="bottom") +
  theme(legend.title=element_blank()) + 
  theme(plot.title = element_text(hjust = 0.5))




df <- fec %>% 
  filter(cid!="Berkshire Hathaway") %>% 
  select(cycle, cid) %>% 
  mutate(cid = factor(cid, 
                      levels = c("Amazon", "Apple", "Microsoft",
                                 "Boeing", "Ford Motor", "General Motors",
                                 "Chevron", "Exxon", "Marathon Oil",
                                 "Citigroup", "Goldman Sachs", "Wells Fargo",
                                 "CVS", "Home Depot", "Kroger", "Walmart"
                                 ))) %>% 
  group_by(cycle, cid) %>% 
  mutate(contrib_count = n()) %>% 
  unique()

lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
ggplot(df, aes(make_datetime(cycle), contrib_count)) +
  geom_line(aes(color=cid), alpha=0.5) +
  geom_point(aes(shape=cid), alpha=0.5) +
  geom_smooth(color='darkblue', aes(fill="Average")) +
  scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
  #scale_y_continuous(labels = comma) +
  scale_y_log10(labels = comma) +
  #scale_color_discrete(guide = guide_legend(title = "Company")) +
  scale_color_manual(values=c(
      "#F5A200", "#DB9100", "#B57800", "#F50094", 
      "#81004E", "#4F0030", "#BF1220", "#BF1400", 
      "#BF3200", "#068100", "#033600", "#044F00", 
      "#007581", "#00484F", "#00C7DB", "#00DFF5"
      )) +
  scale_shape_manual(values=c(
    0, 0, 0, 1, 
    1, 1, 2, 2, 
    2, 4, 4, 4, 
    6, 6, 6, 6
  )) +
  #guides(color=guide_legend(ncol=5)) +
  scale_fill_manual(values = c(Average="#c6c6c6")) +
  xlab("Contribution Cycle") +
  ylab("Number of Schedule A Contributions") +
  ggtitle(paste("Total Individual Contributions by Company")) +
  guides(shape = guide_legend(override.aes = list(size = 5))) +
  #theme(legend.position="bottom") +
  theme(legend.title=element_blank()) + 
  theme(plot.title = element_text(hjust = 0.5))


# df <- fec %>% 
#   select(-`Unnamed: 0`) %>% 
#   mutate(pid = fct_collapse(party_id,
#                             "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
#          pid5 = fct_lump(pid, n=5), 
#          pid3 = fct_lump(pid, n=2)) %>% 
#   filter(pid3 != "Other") %>% 
#   #filter(entity_type_desc == "INDIVIDUAL") %>% #not available pre 2004, just strips old obs
#   mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
#   mutate(lncval = log(contribution_receipt_amount+1))

# df <- fec %>% 
#   select(-`Unnamed: 0`) %>% 
#   mutate(pid = fct_collapse(party_id,
#                             "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
#          pid5 = fct_lump(pid, n=5), 
#          pid3 = fct_lump(pid, n=2)) %>% 
#   filter(pid3 != "Other") %>% 
#   mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
#   mutate(lncval = log(contribution_receipt_amount+1)) %>% 
#   group_by(cycle) %>% 
#   summarize(varpid3 = var(as.numeric(pid3)),
#             varpid5 = var(as.numeric(pid5)))

#table(df$entity_type, df$cycle, useNA = "always")

#Get variance
#var(as.numeric(df$pid3))

#Get Data Specific Company
#filter(cid == "Goldman Sachs")

df_plt_a <- function(company){
  df <- fec %>%
    filter(cid == company) %>%
    select(-`Unnamed: 0`) %>% 
    mutate(pid = fct_collapse(party_id,
                              "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
           pid5 = fct_lump(pid, n=5), 
           pid3 = fct_lump(pid, n=2)) %>% 
    filter(pid3 != "Other") %>% 
    mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
    mutate(lncval = log(contribution_receipt_amount+1))
  return(df)
}

# df <- df_plt_a("Chevron")
# df <- df_plt_a("Ford Motor")
#df <- df_plt_c("Boeing")

df_plt_b <- function(company){
  df <- fec %>% 
    filter(cid == company) %>%
    mutate(pid = fct_collapse(party_id,
                              "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
           pid5 = fct_lump(pid, n=5)) %>% 
    mutate(pid3 = fct_lump(pid, n=2)) %>% 
    filter(pid3 != "Other") %>% 
    mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
    mutate(lncval = log(contribution_receipt_amount+1)) %>% 
    group_by(contribution_receipt_date, pid3) %>% 
    mutate(contrib_count = n())
  return(df)
}

df_plt_c <- function(company){
  df <- fec %>% 
    filter(cid == company) %>%
    mutate(pid = fct_collapse(party_id,
                              "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
           pid5 = fct_lump(pid, n=5)) %>% 
    mutate(pid3 = fct_lump(pid, n=2)) %>% 
    filter(pid3 != "Other") %>% 
    mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
    mutate(lncval = log(contribution_receipt_amount+1)) %>% 
    group_by(cycle, pid3) %>% 
    mutate(contrib_count = n())
  return(df)
}

df_plt_d <- function(company){
  df <- fec %>%
    filter(cid == company) %>% 
    #select(-`Unnamed: 0`) %>% 
    mutate(pid = fct_collapse(party_id,
                              "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
           pid5 = fct_lump(pid, n=5), 
           pid3 = fct_lump(pid, n=2)) %>% 
    filter(pid3 != "Other") %>% 
    mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
    mutate(lncval = log(contribution_receipt_amount+1)) %>% 
    group_by(cycle, cid) %>% 
    summarize(varpid3 = var(as.numeric(pid3)),
              varpid5 = var(as.numeric(pid5))) 
  return(df)
}

# df <- df_plt_d("Goldman Sachs")
# df
# x <- df$varpid3
# mean(x)
# normalize(x)
# c(scale(x))


################################################
## Make Graphs
################################################

wout <- function(plt_type, cid){
  outfile <- paste0("images/", plt_type, "_", str_replace_all(tolower(cid), " ", "_"), ".png")
  return(outfile)
}

## Plot A
## PLOT TS-PARTY - All Individual Contributions (Contribution Level)
plt_a <- function(df){
  lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
  cid <- as.character(df$cid[1])
  outfile <- wout("plt_a", cid)
  g <- ggplot(df, aes(contribution_receipt_date, contribution_receipt_amount, color=pid3)) +
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
  g <- ggplot(df, aes(contribution_receipt_date, contrib_count, color=pid3, shape=pid3)) +
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
  g <- ggplot(df, aes(make_datetime(cycle), contrib_count, color=pid3, shape=pid3)) +
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
  g <- ggplot(df, aes(make_datetime(cycle), contrib_count, color=pid3, shape=pid3)) +
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
    geom_line(aes(make_datetime(cycle), varpid3)) +
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
## Run
################################################

# #plt_a(fec2)
# g1 <- plt_a(df_plt_a("Goldman Sachs"))
# g2 <- plt_b(df_plt_b("Goldman Sachs"))
# g3 <- plt_c(df_plt_c("Goldman Sachs"))
# g4 <- plt_d(df_plt_d("Goldman Sachs"))
# 
# png("output/fig1_gs_test.png",
#        width = 8000, height = 3000,
#        pointsize = 8, res = 600)
# multiplot(g1, g3, g4, cols=3)
# dev.off()

# png("output/fig1_gs_test.png", 
#     width = 6000, height = 3000,
#     pointsize = 12, res = 600)
# multiplot(c(plta, pltb, pltc), cols=3)
# dev.off()

# plt_d(df_plt_d("Goldman Sachs"))
# 
# 
# plt_a(df_plt_a("Exxon"))
# plt_b(df_plt_b("Exxon"))
# plt_c(df_plt_c("Exxon"))
# plt_d(df_plt_d("Exxon"))

# plt_a(df_plt_a("Boeing"))
# plt_b(df_plt_b("Boeing"))
# plt_c(df_plt_c("Boeing"))
# plt_d(df_plt_d("Boeing"))

mp <- function(cid){
  outfile <- paste0("output/", "mp_", str_replace_all(tolower(cid), " ", "_"), ".png")
  png(outfile, 
      width = 8000, height = 3000,
      pointsize = 8, res = 600)
  multiplot(g1, g3, g4, cols=3)
  dev.off()
}

#mp("Goldman Sachs")

companies <- c("Exxon", "Microsoft", "General Motors", "Citigroup", "Goldman Sachs", "Walmart", "Marathon Oil", "Apple", "Berkshire Hathaway", "Amazon", "Boeing", "Home Depot", "Ford Motor", "Kroger", "Chevron", "Wells Fargo", "CVS")
#companies <- c("Goldman Sachs")
#make three graph plots
for (cid in companies){
  g1 <- plt_a(df_plt_a(cid))
  g3 <- plt_c(df_plt_c(cid))
  g4 <- plt_d(df_plt_d(cid))
  
  g5 <- plt_clog(df_plt_c(cid))

  mp(cid)

}

#output <- vector("")




