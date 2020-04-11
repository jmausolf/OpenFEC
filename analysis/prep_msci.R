library(stringr)
library(tidyverse)


#############################
## Create Crosswalk
#############################

match_key = read_csv("msci_data/match_key_edit.csv")

companies_hca <- df_analysis %>% 
  ungroup() %>% 
  select(cid_master) %>% 
  distinct()

crosswalk <- left_join(companies_hca, match_key, by=c("cid_master" = "company")) %>% 
  filter(!is.na(companyname)) %>% 
  ##Remove Odd Company Names
  filter(companyname != 'ADELAIDE BRIGHTON LTD.')


#################################
## Join Crosswalk with MSCI Data
#################################

msci_data <- read_csv("msci_data/MSCI_ALL_1991_2016_stata.csv")

msci_key <- msci_data %>%
  select(companyname, ticker, cusip, year) %>% 
  distinct() %>% 
  arrange(companyname)

## Get Different Match Types and Clean
cusip_match <- left_join(crosswalk, msci_key) %>% 
  filter(!is.na(cusip),
         cusip != 0) %>% 
  select(cid_master, cusip) %>% 
  distinct() %>% 
  left_join(msci_key) %>% 
  arrange(cid_master, year) %>% 
  select(cid_master, companyname, cusip, ticker, year)

ticker_match <- left_join(crosswalk, msci_key) %>% 
  filter(!is.na(ticker)) %>% 
  select(cid_master, ticker) %>% 
  distinct() %>% 
  left_join(msci_key) %>% 
  arrange(cid_master, year) %>% 
  mutate(cid_master_lower = str_to_lower(cid_master),
         companyname_lower = str_to_lower(companyname)) %>% 
  mutate(authorised = str_detect(companyname_lower, cid_master_lower)) %>% 
  filter(authorised == TRUE) %>% 
  select(-companyname_lower, -cid_master_lower, -authorised) %>% 
  select(cid_master, companyname, cusip, ticker, year)

name_match <- left_join(crosswalk, msci_key) %>% 
  select(cid_master, ticker, companyname) %>% 
  distinct() %>% 
  select(-ticker) %>% 
  left_join(msci_key) %>% 
  arrange(cid_master, year) %>% 
  mutate(cid_master_lower = str_to_lower(cid_master),
         companyname_lower = str_to_lower(companyname)) %>% 
  mutate(authorised = str_detect(companyname_lower, cid_master_lower)) %>% 
  filter(authorised == FALSE) %>% 
  select(-companyname_lower, -cid_master_lower, -authorised) %>% 
  select(cid_master, companyname, cusip, ticker, year)

## Join Match Types and Keep Distinct
msci_match_key <- bind_rows(cusip_match, ticker_match, name_match) %>% 
  distinct() %>% 
  arrange(cid_master, year) 



#################################
## Join MSCI Match Key with FEC 
#################################

#TODO Run TS_HSA on Successive Time Windows in A Loop
#i.e. run 1980, (1980, 1982),...(1980...1998)...(1980...2000)...

#Make Base
msci_base <- left_join(msci_match_key, msci_data)

#Drop All NA Cols or Some NA Cols
# msci_base <- Filter(function(x)!all(is.na(x)), msci_base)
# msci_base_complete <- msci_base[ , colSums(is.na(msci_base)) == 0]
# names(msci_base_complete)
# 
# #Join With Post Cluster Data
# 
# msci_cluster_m0 <- left_join(df_post_cluster_m0, msci_base,
#                              by = c("cid_master" = "cid_master", 
#                                     "cycle" = "year"))
# 
# 
# #Small DF
# df_post_cluster_m0_sm <- df_post_cluster_m0 %>% 
#   group_by(cid_master) %>% 
#   mutate(dem = if_else(cluster_party == "DEM", 1, 0),
#          rep = if_else(cluster_party == "REP", 1, 0),
#          oth = if_else(cluster_party == "OTH", 1, 0)
#         ) %>% 
#   select(cid_master, cluster_party,
#          dem, rep, oth,
#          mean_pid2, median_pid2,
#          mean_ps, median_ps,
#          polarization_pid,
#          polarization_ps,
#          polarization_raw_pid,
#          polarization_raw_ps,
#          skewness_pid,
#          skewness_ps,
#          kurtosis_pid,
#          kurtosis_ps,
#          var_pid,
#          var_ps) %>% 
#   summarise_if(is.numeric, mean, na.rm = TRUE) 
# 
# ## All Vars
# msci_base_m0_sm <- msci_base %>% 
#   select(-year) %>% 
#   #select(cid_master, year, DIV_con_A) %>% 
#   group_by(cid_master) %>%
#   summarise_if(is.numeric, list(~mean(.), ~sum(.)), na.rm = TRUE) %>% 
#   ungroup() 
# 
# 
# #Some Vars
# msci_base_m0_sm <- msci_base %>% 
#   select(-year) %>% 
#   #select(cid_master, year, DIV_con_A) %>% 
#   group_by(cid_master) %>%
#   summarise_if(is.numeric, list(~mean(.), ~sum(.)), na.rm = TRUE) %>% 
#   ungroup() 
# 
# ## Remove columns with more than 5% NA
# x <- msci_base_m0_sm 
# msci_base_m0_sm <- x[, -which(colMeans(is.na(x)) > 0.05)]
# 
# ## Mean Impute NA for Those Cols with Less Than 5% NA
# msci_base_m0_sm <- msci_base_m0_sm %>% 
#   mutate_all(~ifelse(is.na(.x), mean(.x, na.rm = TRUE), .x))  
# 
# 
# #Check NA's
# colSums(is.na(msci_base_m0_sm))
# 
# msci_cluster_m0_sm <- inner_join(df_post_cluster_m0_sm, msci_base_m0_sm) %>% 
#   select(-cid_master)  
# 
# colSums(is.na(msci_cluster_m0_sm))
# 
# 
# # msci_cluster_m0_sm <- left_join(df_post_cluster_m0_sm, msci_base_m0_sm,
# #                                 by = c("cid_master" = "cid_master", 
# #                                        "cycle" = "year")) %>% 
# #   ungroup() %>% 
# #   select(-cid_master)
# 
# 
# #TODO SELECT ONLY NUMERIC DATA
# # msci_cluster_m0_sm <- as.data.frame(sapply( msci_cluster_m0_sm, as.numeric ))
# # 
# # 
# # msci_cluster_m0_sm <- as.data.frame(msci_cluster_m0_sm[ , colSums(is.na(msci_cluster_m0_sm)) == 0])
# 
# 
# 
# test_cor_df <- msci_cluster_m0_sm 
# 
# 
# cor(test_cor_df)
# 
# cormat <- round(cor(test_cor_df, method = c("spearman")), 2)
# head(cormat)
# 
# library(psych)
# cormat <- corr.test(test_cor_df, adjust = "none",  method = c("spearman"))
# cormat$p
# 
# library(reshape2)
# melted_cormat <- melt(cormat)
# head(melted_cormat)
# 
# library(ggplot2)
# ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + 
#   geom_tile()
# 
# 
# # Get lower triangle of the correlation matrix
# get_lower_tri<-function(cormat){
#   cormat[upper.tri(cormat)] <- NA
#   return(cormat)
# }
# # Get upper triangle of the correlation matrix
# get_upper_tri <- function(cormat){
#   cormat[lower.tri(cormat)]<- NA
#   return(cormat)
# }
# 
# upper_tri <- get_upper_tri(cormat)
# upper_tri
# 
# # Melt the correlation matrix
# library(reshape2)
# melted_cormat <- melt(upper_tri, na.rm = TRUE)
# # Heatmap
# library(ggplot2)
# ggplot(data = melted_cormat, aes(Var2, Var1, fill = value))+
#   geom_tile(color = "white")+
#   scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
#                        midpoint = 0, limit = c(-1,1), space = "Lab", 
#                        name="Pearson\nCorrelation") +
#   theme_minimal()+ 
#   theme(axis.text.x = element_text(angle = 45, vjust = 1, 
#                                    size = 12, hjust = 1))+
#   coord_fixed()
# 
# 
# 
# 
# ##GGCORRPLOT
# library(ggcorrplot)
# 
# 
# ##Big Corr
# corr <- round(cor(msci_cluster_m0_sm, method = c("spearman")), 2)
# # Compute a matrix of correlation p-values
# p.mat <- cor_pmat(msci_cluster_m0_sm)
# 
# g <- ggcorrplot(corr, p.mat = p.mat, hc.order = FALSE,
#            type = "lower", insig = "blank", tl.cex= 1)
# 
# out_by = paste("msci", "corr", sep = "_")
# outfile <- wout("corr_test", out_by)
# ggsave(outfile, dpi = 1200)
# 
# 
# 
# 
# 
# 
# ##First Pass Select
# 
# #Some Vars
# msci_base_2 <- msci_base %>% 
#   select(-year) %>% 
#   select(cid_master, cgov_con_b, cgov_con_num, cgov_con_x, 
#          cgov_str_num, com_con_b, com_con_d, com_con_num, com_str_a,
#          com_str_b, com_str_num, div_con_a, div_con_c, div_con_d, div_con_num,
#          div_con_x, div_str_b, div_str_c, div_str_d, div_str_e, div_str_f,
#          div_str_g, div_str_h, div_str_num, div_str_x, emp_con_a, emp_con_b,
#          emp_con_c, emp_con_num, emp_con_x, emp_str_num, emp_str_x, env_con_a,
#          env_con_b, env_con_d, env_con_f, env_con_num, env_con_x, env_str_b,
#          env_str_d, env_str_num, hum_str_g,
#          pro_con_e, pro_con_num) %>% 
#   group_by(cid_master) %>%
#   mutate_all(list(as.numeric)) %>% 
#   #summarise_if(is.numeric, list(~mean(.), ~sum(.)), na.rm = TRUE) %>% 
#   summarise_if(is.numeric, list(~sum(.)), na.rm = TRUE) %>% 
#   ungroup() 
# 
# 
# 
# #Check NA's
# colSums(is.na(msci_base_2))
# 
# msci_cluster_base_2 <- inner_join(df_post_cluster_m0_sm, msci_base_2) %>% 
#   select(-cid_master)  
# 
# colSums(is.na(msci_cluster_base_2))
# 
# 
# ##GGCORRPLOT
# library(ggcorrplot)
# 
# 
# ##Big Corr
# corr <- round(cor(msci_cluster_base_2, method = c("spearman")), 2)
# # Compute a matrix of correlation p-values
# p.mat <- cor_pmat(msci_cluster_base_2)
# 
# g <- ggcorrplot(corr, p.mat = p.mat, hc.order = FALSE,
#                 type = "upper", insig = "blank", tl.cex= 3)
# 
# out_by = paste("msci", "corr", sep = "_")
# outfile <- wout("corr_test_2_max", out_by)
# ggsave(outfile, dpi = 1200)
# 
# 
# 
# 
# # finalise_plot(g, "my_test_corr_heat", outfile, footer=FALSE)
# # 


############################
## Diversity - M0
############################

#Small DF
df_post_cluster_m0_sm <- df_post_cluster_m0 %>% 
  group_by(cid_master) %>% 
  mutate(dem = if_else(cluster_party == "DEM", 1, 0),
         rep = if_else(cluster_party == "REP", 1, 0),
         oth = if_else(cluster_party == "OTH", 1, 0)
  ) %>% 
  select(cid_master, cluster_party,
         dem, rep, oth,
         mean_pid2, median_pid2,
         mean_ps, median_ps,
         polarization_pid,
         polarization_ps,
         polarization_raw_pid,
         polarization_raw_ps,
         skewness_pid,
         skewness_ps,
         kurtosis_pid,
         kurtosis_ps,
         var_pid,
         var_ps) %>% 
  summarise_if(is.numeric, mean, na.rm = TRUE) 


#Some Vars
msci_div <- msci_base %>% 
  select(-year) %>% 
  select(cid_master, 
         div_con_c, div_con_d, 
         div_str_c, div_str_d,
         div_str_f,
         div_str_g, 
         div_con_num, div_str_num,
         hum_str_g, emp_con_a) %>% 
  group_by(cid_master) %>%
  mutate_all(list(as.numeric)) %>% 
  #summarise_if(is.numeric, list(~mean(.), ~sum(.)), na.rm = TRUE) %>% 
  summarise_if(is.numeric, list(~sum(.)), na.rm = TRUE) %>% 
  ungroup() 

msci_cluster_div <- inner_join(df_post_cluster_m0_sm, msci_div) %>% 
  select(-cid_master) %>% 
  #Pretty Labels
  rename("Board of Directors - No Women" = div_con_c,
         "Board of Directors - No Minorities" = div_con_d,
         "Board of Directors - Strong Gender Diversity" = div_str_c,
         "Strong Work Life Benefits" = div_str_d,
         "Diversity - Number of Concerns" = div_con_num,
         "Diversity - Number of Strengths" = div_str_num,
         "Progressive Gay & Lesbian Policies" = div_str_g,
         "Employment of the Disabled" = div_str_f,
         "Labor Rights Strength" = hum_str_g,
         "Union Relations Concerns" = emp_con_a,
         
         
         "Democratic Firm" = dem,
         "Republican Firm" = rep,
         "Amphibious Firm" = oth,
         "Mean Party ID [Dem, Rep]" = mean_pid2,
         "Median Party ID [Dem, Rep]" = median_pid2,
         "Mean Partisan Score [Dem, Rep]" = mean_ps,
         "Median Partisan Score [Dem, Rep]" = median_ps
      )
       


##GGCORRPLOT
library(ggcorrplot)


##Big Corr
corr <- round(cor(msci_cluster_div, method = c("spearman")), 2)
corr <- round(cor(msci_cluster_div, method = c("pearson")), 2)
# Compute a matrix of correlation p-values
p.mat <- cor_pmat(msci_cluster_div)

g <- ggcorrplot(corr, p.mat = p.mat, hc.order = FALSE,
                type = "upper", insig = "blank", tl.cex= 7, 
                sig.level = 0.05,
                colors = c("#2129B0", "white", "#BF1200")) 

  # bbc_style() 

out_by = paste("msci", "diversity_m0", sep = "_")
outfile <- wout("corr", out_by)
ggsave(outfile, dpi = 1200)



############################
## Diversity - M1
############################

#Small DF
df_post_cluster_m1_sm <- df_post_cluster_m1 %>% 
  group_by(cid_master) %>% 
  mutate(dem = if_else(cluster_party == "DEM", 1, 0),
         rep = if_else(cluster_party == "REP", 1, 0),
         oth = if_else(cluster_party == "OTH", 1, 0)
  ) %>% 
  select(cid_master, cluster_party,
         dem, rep, oth
         # mean_pid2, median_pid2,
         # mean_ps, median_ps,
         # polarization_pid,
         # polarization_ps,
         # polarization_raw_pid,
         # polarization_raw_ps,
         # skewness_pid,
         # skewness_ps,
         # kurtosis_pid,
         # kurtosis_ps,
         # var_pid,
         # var_ps
         ) %>% 
  summarise_if(is.numeric, mean, na.rm = TRUE) 


#Some Vars
msci_div <- msci_base %>% 
  select(-year) %>% 
  select(cid_master, 
         div_con_c, div_con_d, 
         div_str_c, div_str_d,
         div_str_f,
         div_str_g, 
         div_con_num, div_str_num,
         hum_str_g, emp_con_a) %>% 
  group_by(cid_master) %>%
  mutate_all(list(as.numeric)) %>% 
  #summarise_if(is.numeric, list(~mean(.), ~sum(.)), na.rm = TRUE) %>% 
  summarise_if(is.numeric, list(~sum(.)), na.rm = TRUE) %>% 
  ungroup() 

msci_cluster_div <- inner_join(df_post_cluster_m1_sm, msci_div) %>% 
  select(-cid_master) %>% 
  #Pretty Labels
  rename("Board of Directors - No Women" = div_con_c,
         "Board of Directors - No Minorities" = div_con_d,
         "Board of Directors - Strong Gender Diversity" = div_str_c,
         "Strong Work Life Benefits" = div_str_d,
         "Diversity - Number of Concerns" = div_con_num,
         "Diversity - Number of Strengths" = div_str_num,
         "Progressive Gay & Lesbian Policies" = div_str_g,
         "Employment of the Disabled" = div_str_f,
         "Labor Rights Strength" = hum_str_g,
         "Union Relations Concerns" = emp_con_a,
         
         
         "Democratic Firm" = dem,
         "Republican Firm" = rep,
         "Amphibious Firm" = oth
         # "Mean Party ID [Dem, Rep]" = mean_pid2,
         # "Median Party ID [Dem, Rep]" = median_pid2,
         # "Mean Partisan Score [Dem, Rep]" = mean_ps,
         # "Median Partisan Score [Dem, Rep]" = median_ps
         
  )



##GGCORRPLOT
library(ggcorrplot)


##Big Corr
corr <- round(cor(msci_cluster_div, method = c("spearman")), 2)
# corr <- round(cor(msci_cluster_div, method = c("pearson")), 2)
# Compute a matrix of correlation p-values
p.mat <- cor_pmat(msci_cluster_div)

g <- ggcorrplot(corr, p.mat = p.mat, hc.order = FALSE,
                type = "upper", insig = "blank", tl.cex= 7, 
                sig.level = 0.05,
                colors = c("#2129B0", "white", "#BF1200")) +
    labs(title = "Significant Correlations, HCA Clustered Firms and MSCI Data, 1991-2016") +
    theme(plot.title = element_text(hjust = 0.5)) 

out_by = paste("msci", "diversity_m1", sep = "_")
outfile <- wout("corr", out_by)
ggsave(outfile, dpi = 1200)




############################
## Diversity - M2
############################

#Small DF
df_post_cluster_m2_sm <- df_post_cluster_m2 %>% 
  group_by(cid_master) %>% 
  mutate(dem = if_else(cluster_party == "DEM", 1, 0),
         rep = if_else(cluster_party == "REP", 1, 0),
         oth = if_else(cluster_party == "OTH", 1, 0)
  ) %>% 
  select(cid_master, cluster_party,
         dem, rep, oth,
         mean_pid2, median_pid2,
         mean_ps, median_ps,
         polarization_pid,
         polarization_ps,
         polarization_raw_pid,
         polarization_raw_ps,
         skewness_pid,
         skewness_ps,
         var_pid,
         var_ps) %>% 
  summarise_if(is.numeric, mean, na.rm = TRUE) 


#Some Vars
msci_div <- msci_base %>% 
  select(-year) %>% 
  select(cid_master, 
         div_con_c, div_con_d, 
         div_str_c, div_str_d,
         div_str_f,
         div_str_g, 
         div_con_num, div_str_num,
         hum_str_g, emp_con_a) %>% 
  group_by(cid_master) %>%
  mutate_all(list(as.numeric)) %>% 
  #summarise_if(is.numeric, list(~mean(.), ~sum(.)), na.rm = TRUE) %>% 
  summarise_if(is.numeric, list(~sum(.)), na.rm = TRUE) %>% 
  ungroup() 

msci_cluster_div <- inner_join(df_post_cluster_m2_sm, msci_div) %>% 
  select(-cid_master) %>% 
  #Pretty Labels
  rename("Board of Directors - No Women" = div_con_c,
         "Board of Directors - No Minorities" = div_con_d,
         "Board of Directors - Strong Gender Diversity" = div_str_c,
         "Strong Work Life Benefits" = div_str_d,
         "Diversity - Number of Concerns" = div_con_num,
         "Diversity - Number of Strengths" = div_str_num,
         "Progressive Gay & Lesbian Policies" = div_str_g,
         "Employment of the Disabled" = div_str_f,
         "Labor Rights Strength" = hum_str_g,
         "Union Relations Concerns" = emp_con_a,
         
         
         "Democratic Firm" = dem,
         "Republican Firm" = rep,
         "Amphibious Firm" = oth,
         "Mean Party ID [Dem, Rep]" = mean_pid2,
         "Median Party ID [Dem, Rep]" = median_pid2,
         "Mean Partisan Score [Dem, Rep]" = mean_ps,
         "Median Partisan Score [Dem, Rep]" = median_ps
  )



##GGCORRPLOT
library(ggcorrplot)


##Big Corr
corr <- round(cor(msci_cluster_div, method = c("spearman")), 2)
corr <- round(cor(msci_cluster_div, method = c("pearson")), 2)
# Compute a matrix of correlation p-values
p.mat <- cor_pmat(msci_cluster_div)

g <- ggcorrplot(corr, p.mat = p.mat, hc.order = FALSE,
                type = "upper", insig = "blank", tl.cex= 7, 
                sig.level = 0.05,
                colors = c("#2129B0", "white", "#BF1200")) 

# bbc_style() 

out_by = paste("msci", "diversity_m2", sep = "_")
outfile <- wout("corr", out_by)
ggsave(outfile, dpi = 1200)




############################
## Diversity - M3
############################

#Small DF
df_post_cluster_m3_sm <- df_post_cluster_m3 %>% 
  group_by(cid_master) %>% 
  mutate(dem = if_else(cluster_party == "DEM", 1, 0),
         rep = if_else(cluster_party == "REP", 1, 0),
         oth = if_else(cluster_party == "OTH", 1, 0)
  ) %>% 
  select(cid_master, cluster_party,
         dem, rep, oth,
         mean_pid2, median_pid2,
         mean_ps, median_ps,
         polarization_pid,
         polarization_ps,
         polarization_raw_pid,
         polarization_raw_ps,
         skewness_pid,
         skewness_ps,
         var_pid,
         var_ps) %>% 
  summarise_if(is.numeric, mean, na.rm = TRUE) 


#Some Vars
msci_div <- msci_base %>% 
  select(-year) %>% 
  select(cid_master, 
         div_con_c, div_con_d, 
         div_str_c, div_str_d,
         div_str_f,
         div_str_g, 
         div_con_num, div_str_num,
         hum_str_g, emp_con_a) %>% 
  group_by(cid_master) %>%
  mutate_all(list(as.numeric)) %>% 
  #summarise_if(is.numeric, list(~mean(.), ~sum(.)), na.rm = TRUE) %>% 
  summarise_if(is.numeric, list(~sum(.)), na.rm = TRUE) %>% 
  ungroup() 

msci_cluster_div <- inner_join(df_post_cluster_m3_sm, msci_div) %>% 
  select(-cid_master) %>% 
  #Pretty Labels
  rename("Board of Directors - No Women" = div_con_c,
         "Board of Directors - No Minorities" = div_con_d,
         "Board of Directors - Strong Gender Diversity" = div_str_c,
         "Strong Work Life Benefits" = div_str_d,
         "Diversity - Number of Concerns" = div_con_num,
         "Diversity - Number of Strengths" = div_str_num,
         "Progressive Gay & Lesbian Policies" = div_str_g,
         "Employment of the Disabled" = div_str_f,
         "Labor Rights Strength" = hum_str_g,
         "Union Relations Concerns" = emp_con_a,
         
         
         "Democratic Firm" = dem,
         "Republican Firm" = rep,
         "Amphibious Firm" = oth,
         "Mean Party ID [Dem, Rep]" = mean_pid2,
         "Median Party ID [Dem, Rep]" = median_pid2,
         "Mean Partisan Score [Dem, Rep]" = mean_ps,
         "Median Partisan Score [Dem, Rep]" = median_ps
  )



##GGCORRPLOT
library(ggcorrplot)


##Big Corr
corr <- round(cor(msci_cluster_div, method = c("spearman")), 2)
corr <- round(cor(msci_cluster_div, method = c("pearson")), 2)
# Compute a matrix of correlation p-values
p.mat <- cor_pmat(msci_cluster_div)

g <- ggcorrplot(corr, p.mat = p.mat, hc.order = FALSE,
                type = "upper", insig = "blank", tl.cex= 7, 
                sig.level = 0.05,
                colors = c("#2129B0", "white", "#BF1200")) 

# bbc_style() 

out_by = paste("msci", "diversity_m3", sep = "_")
outfile <- wout("corr", out_by)
ggsave(outfile, dpi = 1200)

