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
library(rbokeh)
library(bbplot)



####################################
## CORE DATA SOURCE
####################################

##Load Data
file = "openFEC.db"
path = "../fec_download/"
filepath = paste0(path, file)
con <- dbConnect(RSQLite::SQLite(), filepath)
fec_indiv <- dbGetQuery(con, "SELECT * FROM individual_partisans") 


##Small DF's to Help Clean Companies
companies <-  fec_indiv %>%
  select(cid_master) %>% 
  distinct()

companies_emp <-  fec_indiv %>%
  select(cid_master, contributor_employer_clean_mode) %>%
  add_count(cid_master, contributor_employer_clean_mode, sort=TRUE) %>% 
  distinct()

companies_occ <-  fec_indiv %>%
  select(cid_master, contributor_occupation_clean_mode) %>%
  add_count(cid_master, contributor_occupation_clean_mode, sort=TRUE) %>% 
  distinct()

  
#############################
## CORE DATA CLEANING
#############################

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
  mutate(id = row_number()) %>% 

  #Remove Questionable cid_master's
  filter(cid_master != 'Southern',
         cid_master != 'Williams',
         cid_master != 'Ball',
         cid_master != 'PVH',
         cid_master != 'Dover',
         
      ) %>% 

  #Remove Questionable employer_clean_mode's
  filter(contributor_employer_clean_mode != 'gap solutions',
         contributor_employer_clean_mode != 'apple graphics',
         !str_detect(contributor_employer_clean_mode, "not.+employed"),
         !str_detect(contributor_employer_clean_mode, "self.+"),
         !str_detect(contributor_employer_clean_mode, "cummins.+law"),
         !str_detect(contributor_employer_clean_mode, "cummins.+al"),
         !str_detect(contributor_employer_clean_mode, "apple+.h"),
         !str_detect(contributor_employer_clean_mode, "apple+.financ*"),
         !str_detect(contributor_employer_clean_mode, "apple+.phar"),
         !str_detect(contributor_employer_clean_mode, "apple+.a"),
         !str_detect(contributor_employer_clean_mode, "apple+.b"),
         !str_detect(contributor_employer_clean_mode, "apple+.co(?!m)"),
         !str_detect(contributor_employer_clean_mode, "apple+.c(?!o)"),
         !str_detect(contributor_employer_clean_mode, "apple+.d"),
         !str_detect(contributor_employer_clean_mode, "apple+.education"),
         !str_detect(contributor_employer_clean_mode, "apple+.f"),
         !str_detect(contributor_employer_clean_mode, "apple+.i(?!nc)"),
         !str_detect(contributor_employer_clean_mode, "apple+.j"),
         !str_detect(contributor_employer_clean_mode, "apple+.l"),
         !str_detect(contributor_employer_clean_mode, "apple+.m"),
         !str_detect(contributor_employer_clean_mode, "apple+.n"),
         !str_detect(contributor_employer_clean_mode, "apple+.o"),
         !str_detect(contributor_employer_clean_mode, "apple+.p(?!ro)"),
         !str_detect(contributor_employer_clean_mode, "apple+.q"),
         !str_detect(contributor_employer_clean_mode, "apple+.ro"),
         !str_detect(contributor_employer_clean_mode, "apple+.s(?!of)"),
         !str_detect(contributor_employer_clean_mode, "apple+.t"),
         !str_detect(contributor_employer_clean_mode, "apple+.ve"),
         !str_detect(contributor_employer_clean_mode, "apple+.w"),
         !str_detect(contributor_employer_clean_mode, "vf+.(?![j]|[o]|wo)"),
         !str_detect(contributor_employer_clean_mode, "global partners+."),
         !str_detect(contributor_employer_clean_mode, "harris+.(?!exe)")
      )
  


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




#################################
## COUNTS PER CID_MASTER/CYCLE
## df_filtered
#################################

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


####################################
## Set Individual Threshold
## df_analysis
####################################

##Number Filter 
nf = 10
df_analysis <- df_filtered %>%
  filter(n_indiv_raw >= nf) %>%
  filter(n_indiv_pid >= nf) %>% 
  filter(n_indiv_ps >= nf) %>% 
  filter(n_contrib >= nf) 


##Delete Excess Data
rm(list=c('dfm', 'df_raw_indiv', 'df_pid_indiv', 'df_ps_indiv', 'df_n_contrib'))
rm(list=c('dfocc', 'fec_indiv'))


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


#Make Constant Firms (Used for Robusness Checks/Appendix)

##Year Filter Function
get_cid_contant_n <- function(df, n, year=1980, filter_var=n_indiv_pid){
  
  filter_var <- enexpr(filter_var)
  
  #Get all Companies in year with >= n (of filter_var)
  df_start_gt_n <- df %>% 
    mutate(contributor_cycle = as.numeric(contributor_cycle)) %>% 
    filter(contributor_cycle == 1980) %>% 
    filter(!!filter_var >= n) %>% 
    select(cid_master) %>% 
    distinct()
  
  #Get all Companies in Anyyear with < 10 indiv pid
  df_any_lt_n <- df %>% 
    filter(!!filter_var < n) %>% 
    select(cid_master) %>% 
    distinct()
  
  
  #Get only companies that exist at start with >=10 
  #and have at least 10 every following year (using antijoin)
  df_constant <- anti_join(df_start_gt_n, df_any_lt_n)
  return(df_constant)
  
}










