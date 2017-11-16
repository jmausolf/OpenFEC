#Load Libraries
library(tidyverse)
library(stargazer)
library(knitr)
library(pastecs)
library(forcats)
library(stringr)
library(lubridate)

#source("assemble_plots.R")

##Load Data
#fec <- read_csv("Exxon_Mobile__merged_deduped_ANALYSIS_cleaned.csv")
fec <- read_csv("Goldman_Sachs__schedule_a__merged_ANALYSIS_cleaned.csv")
#fec <- read_csv("ANALYSIS_cleaned__merged_MASTER.csv")
# fec <- read_csv("ANALYSIS_cleaned__merged_MASTER_v2.csv")
# fec <- read_csv("Boeing__schedule_a__merged_ANALYSIS.csv")
# fec <- read_csv("Boeing__merged_deduped_ANALYSIS_cleaned.csv")

##Make directory
system('mkdir -p images')


################################################
## Clean data
################################################


#Work on Base Cleaning
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
# df <- df_plt_a("Boeing")

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

#fec_plt_b <- df_plt_b("Goldman Sachs")

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
    #scale_color_manual(values=c("#dem", "#rep")) +
    #scale_color_manual(values=c("#262F7F", "#7F0000")) +
    scale_color_manual(values=c("#2129B0", "#BF1200")) +
    xlab("Contribution Date") +
    ylab("Contribution Receipt Amount in USD") +
    ggtitle(paste("Individual Contributions by Party:", cid, sep=" ")) +
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
    scale_color_manual(values=c("#2129B0", "#BF1200")) +
    scale_shape_manual(values = c(3, 1)) +
    xlab("Contribution Date") +
    ylab("Number of Schedule A Contributions") +
    ggtitle(paste("Individual Contributions by Party:", cid, sep=" ")) +
    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) + 
    theme(plot.title = element_text(hjust = 0.5))
  
  #save
  ggsave(outfile)
  
  #return
  return(g)
}

## PLOT C - Cycles by Party
plt_c <- function(df){
  lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
  cid <- as.character(df$cid[1])
  outfile <- wout("plt_c", cid)
  g <- ggplot(df, aes(make_datetime(cycle), contrib_count, color=pid3, shape=pid3)) +
    geom_point(alpha=0.25) +
    geom_line() + 
    scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims) +
    scale_color_manual(values=c("#2129B0", "#BF1200")) +
    scale_shape_manual(values = c(3, 1)) +
    xlab("Contribution Cycle") +
    ylab("Number of Schedule A Contributions") +
    ggtitle(paste("Individual Contributions by Party:", cid, sep=" ")) +
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
    scale_color_manual(values=c("#2129B0", "#BF1200")) +
    scale_shape_manual(values = c(3, 1)) +
    xlab("Contribution Cycle") +
    ylab("Variance of Party Contributions") +
    ggtitle(paste("Partisan Variance of Individual Contributions:", cid, sep=" ")) +
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
g1 <- plt_a(df_plt_a("Goldman Sachs"))
g2 <- plt_b(df_plt_b("Goldman Sachs"))
g3 <- plt_c(df_plt_c("Goldman Sachs"))
g4 <- plt_d(df_plt_d("Goldman Sachs"))

# png("output/fig1_gs_test.png", 
#        width = 6000, height = 3000,
#        pointsize = 12, res = 600)
# multiplot(g1, g2, g3, g4, cols=2)
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


#companies <- c("Exxon", "Microsoft", "General Motors", "Citigroup", "Goldman Sachs", "Walmart", "Marathon Oil", "Apple", "Berkshire Hathaway", "Amazon", "Boeing", "Home Depot", "Ford Motor", "Kroger", "Chevron", "Wells Fargo", "CVS")
# companies <- c("Goldman Sachs")
# for (cid in companies){
#   plt1 <- plt_a(df_plt_a(cid))
#   plt2 <- plt_b(df_plt_b(cid))
#   plt3 <- plt_c(df_plt_c(cid))
#   #plt4 <- plt_d(df_plt_d(cid))
# 
#   png("output/fig1_gs_test.png", 
#       width = 6000, height = 3000,
#       pointsize = 12, res = 600)
#   multiplot(plt1, plt2, plt3, cols=3)
#   dev.off()
# 
# }





