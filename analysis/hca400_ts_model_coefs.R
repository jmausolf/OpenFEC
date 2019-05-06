# ## Model 0
# #Set DF for Model Method
# df <- m0_dist_ts


# #Agnes Evaluation Types
# m <- c( "average", "weighted", "single", "complete", "ward")
# names(m) <- c( "AGNES, UPGMA", "AGNES, WPGMA", "AGNES, Single Linkage", "AGNES, Complete Linkage", "AGNES, Ward's Method")

# #Function to Compute Agnes Coef
# ac <- function(x) {
#   agnes(df, method = x)$ac
# }

# #Agnes Coefs
# coef <- map_dbl(m, ac)
# df_agnes <- data.frame(coef, stringsAsFactors=FALSE)
# df_agnes


# #Diana Coef
# coef <-  diana(df)$dc
# names(coef) <- c("Diana")
# df_diana <- data.frame(coef, stringsAsFactors=FALSE)
# df_diana

# #Combined Coefs
# coefs <- rbind(df_agnes, df_diana)
# coefs_m0 <- coefs %>% 
#   rename("Model 0" = "coef")




## Model 1
#Set DF for Model Method
df <- m1_dist_ts


#Agnes Evaluation Types
m <- c( "average", "weighted", "single", "complete", "ward")
names(m) <- c( "AGNES, UPGMA", "AGNES, WPGMA", "AGNES, Single Linkage", "AGNES, Complete Linkage", "AGNES, Ward's Method")

#Function to Compute Agnes Coef
ac <- function(x) {
  agnes(df, method = x)$ac
}

#Agnes Coefs
coef <- map_dbl(m, ac)
df_agnes <- data.frame(coef, stringsAsFactors=FALSE)
df_agnes


#Diana Coef
coef <-  diana(df)$dc
names(coef) <- c("Diana")
df_diana <- data.frame(coef, stringsAsFactors=FALSE)
df_diana

#Combined Coefs
coefs <- rbind(df_agnes, df_diana)
coefs_m1 <- coefs %>% 
  rename("Model 1" = "coef")




# ## Model 2
# #Set DF for Model Method
# df <- m2_dist_ts


# #Agnes Evaluation Types
# m <- c( "average", "weighted", "single", "complete", "ward")
# names(m) <- c( "AGNES, UPGMA", "AGNES, WPGMA", "AGNES, Single Linkage", "AGNES, Complete Linkage", "AGNES, Ward's Method")

# #Function to Compute Agnes Coef
# ac <- function(x) {
#   agnes(df, method = x)$ac
# }

# #Agnes Coefs
# coef <- map_dbl(m, ac)
# df_agnes <- data.frame(coef, stringsAsFactors=FALSE)
# df_agnes


# #Diana Coef
# coef <-  diana(df)$dc
# names(coef) <- c("Diana")
# df_diana <- data.frame(coef, stringsAsFactors=FALSE)
# df_diana

# #Combined Coefs
# coefs <- rbind(df_agnes, df_diana)
# coefs_m2 <- coefs %>% 
#   rename("Model 2" = "coef")



## Model 3
#Set DF for Model Method
df <- m3_dist_ts


#Agnes Evaluation Types
m <- c( "average", "weighted", "single", "complete", "ward")
names(m) <- c( "AGNES, UPGMA", "AGNES, WPGMA", "AGNES, Single Linkage", "AGNES, Complete Linkage", "AGNES, Ward's Method")

#Function to Compute Agnes Coef
ac <- function(x) {
  agnes(df, method = x)$ac
}

#Agnes Coefs
coef <- map_dbl(m, ac)
df_agnes <- data.frame(coef, stringsAsFactors=FALSE)
df_agnes


#Diana Coef
coef <-  diana(df)$dc
names(coef) <- c("Diana")
df_diana <- data.frame(coef, stringsAsFactors=FALSE)
df_diana

#Combined Coefs
coefs <- rbind(df_agnes, df_diana)
coefs_m3 <- coefs %>% 
  rename("Model 2" = "coef")



## Model 4
#Set DF for Model Method
df <- m4_dist_ts


#Agnes Evaluation Types
m <- c( "average", "weighted", "single", "complete", "ward")
names(m) <- c( "AGNES, UPGMA", "AGNES, WPGMA", "AGNES, Single Linkage", "AGNES, Complete Linkage", "AGNES, Ward's Method")

#Function to Compute Agnes Coef
ac <- function(x) {
  agnes(df, method = x)$ac
}

#Agnes Coefs
coef <- map_dbl(m, ac)
df_agnes <- data.frame(coef, stringsAsFactors=FALSE)
df_agnes


#Diana Coef
coef <-  diana(df)$dc
names(coef) <- c("Diana")
df_diana <- data.frame(coef, stringsAsFactors=FALSE)
df_diana

#Combined Coefs
coefs <- rbind(df_agnes, df_diana)
coefs_m4 <- coefs %>% 
  rename("Model 3" = "coef")



########################################
## Combined Model Determination
########################################

# model_name <- rownames(coefs_m0)
# coefs_all_periods <- cbind(model_name, coefs_m0, coefs_m1, coefs_m2, coefs_m3, coefs_m4) %>% 
#   rename("Model, Method" = model_name)
# coefs_all_periods

coefs_all_periods <- cbind(model_name, coefs_m1, coefs_m3, coefs_m4) %>% 
  rename("Model, Method" = model_name)
coefs_all_periods

save_stargazer("output/tables/hca400_ts_coefs.tex",
               as.data.frame(coefs_all_periods), header=FALSE, type='latex',
               font.size = "footnotesize",
               title = "HCA Agglomerative (Agnes) or Divisive (Diana) Coefficients for Three Time Series Feature Sets, 1980-2018",
               label = "tab:model_coefs",
               summary = FALSE,
               rownames = FALSE)

