####################################
## CORE LIBRARIES
####################################

##Load Libraries
library(tidyverse)
library(stargazer)
library(knitr)
library(pastecs)
library(forcats)
library(stringr)
library(lubridate)
library(scales)
library(DBI)
library(ggsci)
library(bbplot)


####################################
## CORE DATA SOURCE
####################################

##Load Data
file = "openFEC.db"
#file = "openFEC_full_R_test.db"
path = "../fec_download/"
filepath = paste0(path, file)
con <- dbConnect(RSQLite::SQLite(), filepath)
fec_indiv <- dbGetQuery(con, "SELECT * FROM individual_partisans") 

#write to csv temp
#write_csv(fec, "openfec_sa_cleaned_041318.csv")


  
#####################
## CORE DATA CLEANING


dfm <- fec_indiv %>% 
  mutate(pid = fct_collapse(party_id_mode,
                            "REP" = c("REP", "Rep", "['REP' 'Rep']", "['' 'REP']"),
                            "DEM" = c("DEM", "Dem", "['' 'DEM']"),
                            "NA-ERROR-UNKNOWN" = c("UNK_OTHER", "UNK", "GRE_UNK_OTHER")),
         pid3 = fct_lump(pid, n=2)) %>% 
  mutate(pid2 = if_else(pid3!="Other", pid3, NULL, missing = NULL)) %>% 
  mutate(partisan_score = as.numeric(partisan_score_mean)) %>%
  mutate(ps01 = ((partisan_score+1)/2)) %>% 
  mutate(occ = fct_lump(contributor_occupation_clean_mode, n=10)) %>% 
  mutate(cycle = as.numeric(contributor_cycle)) %>% 
  mutate(id = row_number())
  


##Clean Occupations
dfocc <- dfm %>% 
  mutate(occlevels = 'OTHERS') %>% 
  mutate(occlevels = if_else(executive_emp_mode == "True" | executive_occ_mode == "True", "CSUITE", occlevels),
         occlevels = if_else(director_emp_mode == "True" | director_occ_mode == "True", "DIRECTOR", occlevels),
         occlevels = if_else(manager_emp_mode == "True" | manager_occ_mode == "True", "MANAGER", occlevels)) %>% 
  #Correction for Levels pre 2004 to others
  mutate(occlevels = if_else(occlevels != "OTHERS" & cycle < 2004, "OTHERS", occlevels)) %>% 
  mutate(occ3 = fct_collapse(occlevels,
                             "MANAGEMENT" = c("MANAGER", "DIRECTOR"))) %>% 
  mutate(occ4 = fct_collapse(occ3, ALL = c("CSUITE", "MANAGEMENT", "OTHERS"))) %>% 
  filter(!is.na(contributor_name_clean),
         contributor_name_clean != "", 
         contributor_cycle >= 1980 & contributor_cycle < 2020)


# dfocc3 <- dfocc %>% 
#   select(cycle, pid3, pid2, partisan_score, cid_master, occlevels, occ3, occ4, n_indiv, n_contrib) %>%
#   mutate(ps01 = ((partisan_score+1)/2)) %>% 
#   filter(!is.na(pid2))




#####################
## COUNTS PER CID_MASTER/CYCLE

##Get Number of Contributions by the Sum of Unique Sub Ids
df_n_contrib <- dfocc %>% 
  mutate(sub_id_count = as.numeric(sub_id_count)) %>% 
  group_by(cid_master, contributor_cycle) %>% 
  summarise('n_contrib' = sum(sub_id_count))

##Get the Number of Individuals within a Company in an Election Cycle
##Get raw indiv count (including those with non-pid2 parties and missing ps)
df_raw_indiv <- dfocc %>% 
  add_count(cid_master, contributor_cycle, sort=TRUE)  %>%
  rename('n_indiv_raw' = n) 


##Get only valid pid2 count
df_pid_indiv <- dfocc %>%
  filter(!is.na(pid2)) %>% 
  add_count(cid_master, contributor_cycle, sort=TRUE)  %>%
  rename('n_indiv_pid' = n) %>% 
  select(cid_master, contributor_cycle, n_indiv_pid) %>% 
  distinct()


##Get only valid partisan score count
df_ps_indiv <- dfocc %>%
  filter(!is.na(partisan_score)) %>% 
  add_count(cid_master, contributor_cycle, sort=TRUE)  %>%
  rename('n_indiv_ps' = n) %>% 
  select(cid_master, contributor_cycle, n_indiv_ps) %>% 
  distinct()


##Join Different Metrics
df_filtered <- df_raw_indiv %>% 
  left_join(df_pid_indiv) %>% 
  left_join(df_ps_indiv) %>% 
  left_join(df_n_contrib)



##Delete Excess Data
rm(list=c('dfm', 'df_raw_indiv', 'df_pid_indiv', 'df_ps_indiv', 'df_n_contrib'))

####################################
## CORE FOLDERS
####################################

system("mkdir -p output")
system("mkdir -p output/plots")
system("mkdir -p output/tables")


####################################
## CORE UTIL FUNCTIONS
####################################

#Change Append = TRUE to Not Overwrite Files
save_stargazer <- function(output.file, ...) {
  output <- capture.output(stargazer(...))
  cat(paste(output, collapse = "\n"), "\n", file=output.file, append = FALSE)
}


wout <- function(plt_type, cid){
  outfile <- paste0("output/plots/", plt_type, "_", str_replace_all(tolower(cid), " ", "_"), ".png")
  return(outfile)
}

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}










