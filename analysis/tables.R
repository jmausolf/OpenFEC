


library(tidyverse)
library(stargazer)
# library(Hmisc)
# library(stringr)
# library(car)
library(forcats)
library(ggsci)

#Change Append = TRUE to Not Overwrite Files
save_stargazer <- function(output.file, ...) {
  output <- capture.output(stargazer(...))
  cat(paste(output, collapse = "\n"), "\n", file=output.file, append = FALSE)
}





##Make directory
system('mkdir -p images')

wout <- function(plt_type, cid){
  outfile <- paste0("images/", plt_type, "_", str_replace_all(tolower(cid), " ", "_"), ".png")
  return(outfile)
}

################################################
## Clean data
################################################







#Summary Stats for Variables in Models
df_stats <- dfocc %>% 
  select(cycle, 
         contributor_name,
         cid,
         cid_master,
         contributor_transaction_amt,
         party_id,
         pid2,
         partisan_score,
         #pid3, 
         #pid5, 
         occlevels, 
         contributor_occupation_clean) %>% 
  mutate(occ3 = fct_collapse(occlevels,
                             "MANAGEMENT" = c("MANAGER", "DIRECTOR"),
                             "OTHERS" = c("ENGINEER", "Other"))) %>% 
  mutate(contributor_name = as.numeric(as.factor(contributor_name)),
         party_id = as.numeric(as.factor(party_id)),
         pid2 = as.numeric(pid2),
         #pid3 = as.numeric(pid3),
         #pid5 = as.numeric(pid5),
         cid = as.numeric(as.factor(cid)),
         cid_master = as.numeric(as.factor(cid_master)),
         occ3 = as.numeric(occ3),
         contributor_occupation = as.numeric(as.factor(contributor_occupation_clean))) %>% 
  rename("Contributor Name" = contributor_name,
         "Contribution Receipt Amount" = contributor_transaction_amt,
         "Presidential Election Cycle" = cycle,
         "Party Identification" = party_id,
         "Major Party ID" = pid2,
         "Partisan Score" = partisan_score,
         "Company ID" = cid,
         "Company Master ID" = cid_master,
         "Contributor Occupation" = contributor_occupation_clean,
         "Organizational Hierarchies" = occ3)


save_stargazer("output/descriptive_stats.tex",
               as.data.frame(df_stats), header=FALSE, type='latex',
               median = TRUE,
               font.size = "scriptsize",
               digits = 2,
               title = "Descriptive Statistics from the Federal Election Commission (FEC)" )

#stargazer(as.data.frame(df_stats), type = "text", median = TRUE)




########################################
#Variance tables
########################################


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




#Big Tables (Use Default dfocc)

#CID vs CID MASTER

#Get Variance by Organization Levels
df1a <-  dfocc3 %>%
  select(cycle, cid_master, pid2, occ3) %>% 
  filter(!is.na(pid2),
         !is.na(occ3)) %>%
  mutate(occ = occ3) %>% 
  group_by(cycle, cid_master, occ) %>% 
  summarize(varpid = var(as.numeric(pid2)))

#Get Variance All Levels
df1b <-  dfocc3 %>%
  select(cycle, cid_master, pid2, occ3) %>% 
  filter(!is.na(pid2),
         !is.na(occ3)) %>%
  mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>% 
  mutate(occ = occ4) %>% 
  group_by(cycle, cid_master, occ) %>% 
  summarize(varpid = var(as.numeric(pid2)))

df1 <- rbind(df1a, df1b) %>% 
  mutate(occ = factor(occ, 
                      levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL")))


vt_all_cidmaster <- var_sum_table(df1, 
                                  "output/var_all_cidmaster.tex", 
                                  "Variance of Major Party Contributions by Organizational Hierarchy - CID Master")
vt_cycle_cidmaster <- var_cycle_table(df1, 
                                      "output/var_cycle_cidmaster.tex", 
                                      "Variance of Major Party Contributions by Occupation and Year - CID Master")




df_var_cycle_graph <- df1 %>% 
  group_by(occ, cycle) %>% 
  summarise(meanvar = mean(varpid, na.rm = T)) %>%
  filter(!is.nan(meanvar)) 

outfile <- wout("plt_partisan_variance_occ", "by_all_companies_cid_master")
ggplot(df_var_cycle_graph, aes(make_datetime(cycle), meanvar)) +
  #geom_point(aes(shape=cid), alpha=0.5) +
  geom_smooth(color='#B28E02', alpha=0.15, size=0.5) +
  geom_line(aes(color=occ), alpha=0.9) +
  geom_point(aes(shape=occ), alpha=1) +
  #scale_color_manual(values=c("#0F6D0C", "#BF1200", "#BF1200", "#BF1200" )) +
  #scale_color_jama() +
  scale_color_npg() +
  scale_shape_manual(values=c(10, 1, 2, 6)) +
  #scale_x_datetime(date_labels = "%Y", date_breaks = "2 year", limits = lims) +
  scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
  xlab("Contribution Cycle") +
  ylab("Variance of Company Partisan Contributions") +
  ggtitle(paste("Variance of Company Party Contributions by Occupation and Election Cycle - CID Master")) +
  guides(shape = guide_legend(override.aes = list(size = 5))) +
  theme(legend.title=element_blank()) + 
  theme(legend.position="bottom") +
  theme(plot.title = element_text(hjust = 0.5))
ggsave(outfile, width = 10, height = 6)





#CID vs CID MASTER

#Get Variance by Organization Levels
df1a <-  dfocc3 %>%
  select(cycle, cid, pid2, occ3) %>% 
  filter(!is.na(pid2),
         !is.na(occ3)) %>%
  mutate(occ = occ3) %>% 
  group_by(cycle, cid, occ) %>% 
  summarize(varpid = var(as.numeric(pid2)))

#Get Variance All Levels
df1b <-  dfocc3 %>%
  select(cycle, cid, pid2, occ3) %>% 
  filter(!is.na(pid2),
         !is.na(occ3)) %>%
  mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>% 
  mutate(occ = occ4) %>% 
  group_by(cycle, cid, occ) %>% 
  summarize(varpid = var(as.numeric(pid2)))

df1 <- rbind(df1a, df1b) %>% 
  mutate(occ = factor(occ, 
                      levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL")))


df_var_cycle_graph <- df1 %>% 
  group_by(occ, cycle) %>% 
  summarise(meanvar = mean(varpid, na.rm = T)) %>%
  filter(!is.nan(meanvar)) 

outfile <- wout("plt_partisan_variance_occ", "by_all_companies_cid")
ggplot(df_var_cycle_graph, aes(make_datetime(cycle), meanvar)) +
  #geom_point(aes(shape=cid), alpha=0.5) +
  geom_smooth(color='#B28E02', alpha=0.15, size=0.5) +
  geom_line(aes(color=occ), alpha=0.9) +
  geom_point(aes(shape=occ), alpha=1) +
  #scale_color_manual(values=c("#0F6D0C", "#BF1200", "#BF1200", "#BF1200" )) +
  #scale_color_jama() +
  scale_color_npg() +
  scale_shape_manual(values=c(10, 1, 2, 6)) +
  #scale_x_datetime(date_labels = "%Y", date_breaks = "2 year", limits = lims) +
  scale_x_datetime(date_labels = "%Y", date_breaks = "2 year") +
  xlab("Contribution Cycle") +
  ylab("Variance of Company Partisan Contributions") +
  ggtitle(paste("Variance of Company Party Contributions by Occupation and Election Cycle - CID")) +
  guides(shape = guide_legend(override.aes = list(size = 5))) +
  theme(legend.title=element_blank()) + 
  theme(legend.position="bottom") +
  theme(plot.title = element_text(hjust = 0.5))
ggsave(outfile, width = 10, height = 6)




#Small Tables
dfocc3_small <- dfocc3 %>% 
  filter(cycle >= 2004)

#Get Variance by Organization Levels
df1a <-  dfocc3_small %>%
  select(cycle, cid_master, pid2, occ3) %>% 
  filter(!is.na(pid2),
         !is.na(occ3)) %>%
  mutate(occ = occ3) %>% 
  group_by(cycle, cid_master, occ) %>% 
  summarize(varpid = var(as.numeric(pid2)))

#Get Variance All Levels
df1b <-  dfocc3_small %>%
  select(cycle, cid_master, pid2, occ3) %>% 
  filter(!is.na(pid2),
         !is.na(occ3)) %>%
  mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>% 
  mutate(occ = occ4) %>% 
  group_by(cycle, cid_master, occ) %>% 
  summarize(varpid = var(as.numeric(pid2)))

df1 <- rbind(df1a, df1b) %>% 
  mutate(occ = factor(occ, 
                      levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL")))


vt_all_cidmaster_small <- var_sum_table(df1, 
                                  "output/var_all_cidmaster_small.tex", 
                                  "Variance of Major Party Contributions by Organizational Hierarchy - CID Master")
vt_cycle_cidmaster_small <- var_cycle_table(df1, 
                                      "output/var_cycle_cidmaster_small.tex", 
                                      "Variance of Major Party Contributions by Occupation and Year - CID Master")





#Small - CID, NOT MASTER

#Get Variance by Organization Levels
df1a <-  dfocc3_small %>%
  select(cycle, cid, pid2, occ3) %>% 
  filter(!is.na(pid2),
         !is.na(occ3)) %>%
  mutate(occ = occ3) %>% 
  group_by(cycle, cid, occ) %>% 
  summarize(varpid = var(as.numeric(pid2)))

#Get Variance All Levels
df1b <-  dfocc3_small %>%
  select(cycle, cid, pid2, occ3) %>% 
  filter(!is.na(pid2),
         !is.na(occ3)) %>%
  mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>% 
  mutate(occ = occ4) %>% 
  group_by(cycle, cid, occ) %>% 
  summarize(varpid = var(as.numeric(pid2)))

df1 <- rbind(df1a, df1b) %>% 
  mutate(occ = factor(occ, 
                      levels = c("CSUITE", "MANAGEMENT", "OTHERS", "ALL")))


vt_all_cid_small <- var_sum_table(df1, 
                                        "output/var_all_cid_small.tex", 
                                        "Variance of Major Party Contributions by Organizational Hierarchy - CID")
vt_cycle_cid_small <- var_cycle_table(df1, 
                                            "output/var_cycle_cid_small.tex", 
                                            "Variance of Major Party Contributions by Occupation and Year - CID")





