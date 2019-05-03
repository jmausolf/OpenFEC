####################################
## RUN INDIV ANALYSIS
####################################

#setwd('~/Box Sync/Dissertation_v2/CH1_OpenFEC/OpenFEC_test_MASTER/analysis/')

##Load Data Source and Core Functions
source("indiv_source.R")
source("indiv_vartab_varplot_functions.R")
source("indiv_partisan_functions.R")


#############################
## Descriptive Statitistics
#############################

source("indiv_desctab.R")
source("indiv_desctab_appendix.R")


#####################################
## Make Polarization / Sim Measures
#####################################

source("indiv_make_polarization_similarity_measures.R")


#############################
## Base Variance Plots
#############################

source("indiv_vartab_varplot_main.R")

#TODO
#make plots for skewness, and polarization

#add polarization measures to df_analysis
#make measures for similarity, Jaquard between firms




#############################
## HCA
#############################

source("hca400_functions.R")
source("hca400.R")


source("indiv_source.R")
source("indiv_vartab_varplot_functions.R")
source("indiv_partisan_functions.R")
source("hca400_loop.R")

source("get_indiv_party_switch.R")

#############################
## Post HCA
#############################

source("indiv_vartab_varplot_hca.R")
source("indiv_mean_party_hca.R")
source("indiv_median_party_hca.R")



source("indiv_mean_party_hca_loop.R")