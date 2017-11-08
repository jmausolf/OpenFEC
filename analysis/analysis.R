#Load Libraries
library(tidyverse)
library(stargazer)
library(knitr)
library(pastecs)
library(forcats)
library(stringr)


##Load Data
#fec <- read_csv("Exxon_Mobile__merged_deduped_ANALYSIS_cleaned.csv")
fec <- read_csv("Goldman_Sachs__merged_deduped_ANALYSIS_cleaned.csv")

##Make directory
system('mkdir -p images')


################################################
## Clean data
################################################
fec3 <- fec %>% 
  mutate(pid = fct_collapse(party_id,
                                  "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
         pid = fct_lump(pid, n=5)) %>% 
  filter(pid == c("DEMOCRATIC PARTY", "REPUBLICAN PARTY"))


fec_plt_a <- fec %>% 
  mutate(pid = fct_collapse(party_id,
                            "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
         pid5 = fct_lump(pid, n=5)) %>% 
  mutate(pid3 = fct_lump(pid, n=2)) %>% 
  filter(pid3 != "Other") %>% 
  mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
  mutate(lncval = log(contribution_receipt_amount+1)) %>% 
  #Get Data Specific Company
  filter(cid == "Goldman Sachs")

df_plt_a <- function(company){
  df <- fec %>% 
    mutate(pid = fct_collapse(party_id,
                              "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
           pid5 = fct_lump(pid, n=5)) %>% 
    mutate(pid3 = fct_lump(pid, n=2)) %>% 
    filter(pid3 != "Other") %>% 
    mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
    mutate(lncval = log(contribution_receipt_amount+1)) %>% 
    #Get Data Specific Company
    filter(cid == company)
  return(df)
}

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
  ggplot(df, aes(contribution_receipt_date, contribution_receipt_amount, color=pid3)) +
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
  return(plt_a)
}


################################################
## Run
################################################

#plt_a(fec2)
plt_a(df_plt_a("Goldman Sachs"))


