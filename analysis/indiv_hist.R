####################################
## Load SOURCE
####################################

source("indiv_source.R")




hist(as.numeric(fec$partisan_score_mean))





ggplot(fec) +
  geom_histogram(aes(as.numeric(partisan_score_mean))) +
  facet_wrap(~contributor_cycle)



df <- df1b %>% 
  mutate(ps_d = if_else(partisan_score < 0, partisan_score, NULL, missing = NULL)) %>% 
  mutate(ps_r = if_else(partisan_score > 0, partisan_score, NULL, missing = NULL))

ggplot(df1b) +
  #geom_histogram(aes(as.numeric(partisan_score))) +
  geom_histogram(aes(as.numeric(partisan_score), ..count.., color = cid_master), bins = 30, position = "stack", alpha=0.15) +
  facet_wrap(~cycle) +
  theme(legend.position="none") +
  theme(legend.title=element_blank()) + 
  scale_y_log10()


ggplot(df) +
  #geom_histogram(aes(as.numeric(partisan_score))) +
  geom_histogram(aes(as.numeric(ps_d), ..count..), bins = 15, position = "stack", alpha=0.15) +
  geom_histogram(aes(as.numeric(ps_r), ..count..), bins = 15, position = "stack", alpha=0.15) +
  #facet_wrap(~cycle) +
  scale_fill_manual(values=c("#2129B0", "#BF1200")) +
  theme(legend.position="none") +
  theme(legend.title=element_blank()) + 
  scale_y_log10()


ggplot(df1b) +
  #geom_histogram(aes(as.numeric(partisan_score))) +
  geom_histogram(aes(as.numeric(pid3), color = cid_master), bins = 10, alpha=0.15) +
  facet_wrap(~cycle) +
  theme(legend.position="none") +
  theme(legend.title=element_blank())