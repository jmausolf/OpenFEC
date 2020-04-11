library(ggpubr)
source("bb_finalise_plot_academic.R")

get_polarization <- df_polarization %>% 
  filter(cid_master == "Marathon Petroleum" | cid_master == "Alphabet",
         cycle == "2018",
         occ == "ALL") %>% 
  select(polarization_raw_pid)

pol_vals <- as.list(get_polarization)[[1]]
pol_vals

pol_val_google <- pol_vals[1]
pol_val_marathon <- pol_vals[2]
  
as.character(round(pol_val_google, 2))

get_polarization

mp <- df_analysis %>%
  filter(cid_master == "Marathon Petroleum",
         cycle == "2018") %>% 
  group_by(cid_master, cycle) %>% 
  select(cid_master, cycle, occ3, party_id_count, pid2) %>% 
  mutate(pid2n = as.numeric(pid2)) %>% 
  filter(!is.na(pid2n)) %>% 
  ungroup() %>% 
  select(pid2n) %>% 
  
  ggplot(aes(pid2n)) + 
  geom_density(fill=colors_rep[2]) +
  geom_vline(aes(xintercept=mean(pid2n)),
             color="#BF1200", linetype="dashed", size=1) +
  bbc_style() +
  theme(axis.title = element_text(size = 18)) +
  scale_x_continuous(breaks=c(1,2), labels=c("DEM", "REP")) +
  xlab("Partisan ID [DEM, REP]") +
  ylab("Density") +
  labs(title = "Marathon Petroleum - 2018",
       subtitle = paste("Partisan Polarization = ", as.character(round(pol_val_marathon, 1)))) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  geom_hline(yintercept = 0.0, size = 1, colour="#333333")
  
  


go <- df_analysis %>%
  filter(cid_master == "Alphabet",
         cycle == "2018") %>% 
  group_by(cid_master, cycle) %>% 
  select(cid_master, cycle, occ3, party_id_count, pid2) %>% 
  mutate(pid2n = as.numeric(pid2)) %>% 
  filter(!is.na(pid2n)) %>% 
  ungroup() %>% 
  select(pid2n) %>% 
  
  ggplot(aes(pid2n)) + 
  geom_density(fill=colors_dem[2]) +
  geom_vline(aes(xintercept=mean(pid2n)),
             color="#2129B0", linetype="dashed", size=1) +
  bbc_style() +
  theme(axis.title = element_text(size = 18)) +
  scale_x_continuous(breaks=c(1,2), labels=c("DEM", "REP")) +
  xlab("Partisan ID [DEM, REP]") +
  ylab("Density") +
  labs(title = "Alphabet (Google) - 2018",
       subtitle = paste("Partisan Polarization = ", as.character(round(pol_val_google, 1)))) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  geom_hline(yintercept = 0.0, size = 1, colour="#333333")
  


combined_plot <- ggarrange(go, mp)
out_by = paste("2018", "density_plot", sep = "_")
outfile <- wout("google_marathon", out_by)
finalise_plot(combined_plot, "", outfile, footer=FALSE, width_pixels = 1000)


#################
## AMP

get_polarization_gs <- df_polarization %>% 
  filter(cid_master == "Goldman Sachs Group" | cid_master == "General Motors",
         cycle == "2018",
         occ == "ALL") %>% 
  select(polarization_raw_pid)

pol_vals <- as.list(get_polarization_gs)[[1]]
pol_vals

pol_val_gs <- pol_vals[2]
pol_val_gm <- pol_vals[1]


get_polarization

gs <- df_analysis %>%
  filter(cid_master == "Goldman Sachs Group",
         cycle == "2018") %>% 
  group_by(cid_master, cycle) %>% 
  select(cid_master, cycle, occ3, party_id_count, pid2) %>% 
  mutate(pid2n = as.numeric(pid2)) %>% 
  filter(!is.na(pid2n)) %>% 
  ungroup() %>% 
  select(pid2n) %>% 
  
  ggplot(aes(pid2n)) + 
  geom_density(fill=colors_neutral[2]) +
  geom_vline(aes(xintercept=mean(pid2n)),
             color="#3A084A", linetype="dashed", size=1) +
  bbc_style() +
  theme(axis.title = element_text(size = 18)) +
  scale_x_continuous(breaks=c(1,2), labels=c("DEM", "REP")) +
  xlab("Partisan ID [DEM, REP]") +
  ylab("Density") +
  labs(title = "Goldman Sachs - 2018",
       subtitle = paste("Partisan Polarization = ", as.character(round(pol_val_gs, 1)))) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  geom_hline(yintercept = 0.0, size = 1, colour="#333333")



##Interesting to Look at GM Across Cycles,
##Distribution, flows back and forth from one pol to bipol and back again
##Could be an interesting visual to pick a few example companies,
##Plot the Distributions by Cycle Over Time
gm <- df_analysis %>%
  filter(cid_master == "General Motors",
         cycle == "2018") %>% 
  group_by(cid_master, cycle) %>% 
  select(cid_master, cycle, occ3, party_id_count, pid2) %>% 
  mutate(pid2n = as.numeric(pid2)) %>% 
  filter(!is.na(pid2n)) %>% 
  ungroup() %>% 
  select(pid2n) %>% 
  
  ggplot(aes(pid2n)) + 
  geom_density(fill=colors_neutral[2]) +
  geom_vline(aes(xintercept=mean(pid2n)),
             color="#3A084A", linetype="dashed", size=1) +
  bbc_style() +
  theme(axis.title = element_text(size = 18)) +
  scale_x_continuous(breaks=c(1,2), labels=c("DEM", "REP")) +
  xlab("Partisan ID [DEM, REP]") +
  ylab("Density") +
  labs(title = "General Motors - 2018",
       subtitle = paste("Partisan Polarization = ", as.character(round(pol_val_gm, 1)))) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  geom_hline(yintercept = 0.0, size = 1, colour="#333333")


