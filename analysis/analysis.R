library(tidyverse)
library(stargazer)
library(knitr)
library(pastecs)
library(forcats)


fec <- read_csv("Exxon_Mobile__merged_deduped_ANALYSIS_cleaned.csv")
fec <- read_csv("Goldman_Sachs__merged_deduped_ANALYSIS_cleaned.csv")


fec3 <- fec %>% 
  mutate(pid = fct_collapse(party_id,
                                  "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
         pid = fct_lump(pid, n=5)) %>% 
  filter(pid == c("DEMOCRATIC PARTY", "REPUBLICAN PARTY"))


fec2 <- fec %>% 
  mutate(pid = fct_collapse(party_id,
                            "NA-ERROR-UNKNOWN" = c("UNKNOWN", "ERROR", "NONE", "None")),
         pid5 = fct_lump(pid, n=5)) %>% 
  mutate(pid3 = fct_lump(pid, n=2)) %>% 
  filter(pid3 != "Other") %>% 
  mutate(occ = fct_lump(contributor_occupation, n=10)) %>% 
  mutate(lncval = log(contribution_receipt_amount+1))

table(fec$party_id)
table(fec$pid)
table(fec2$pid3)
table(fec2$contributor_occupation)
table(fec2$occ)
table(fec2$contribution_receipt_amount)


ggplot(fec) +
   geom_bar(aes(party_id, color=employer_clean)) 

ggplot(fec) +
  geom_bar(aes(party_id, color=contributor_occupation)) 


#intersting, seems to be divide between executives and others
ggplot(fec) +
  geom_bar(aes(party_id)) +
  facet_wrap(~contributor_occupation)

ggplot(fec2) +
  geom_bar(aes(pid3)) +
  facet_wrap(~occ)

#Number of Contributions by Party ID and Cycle
#Great Plot
ggplot(fec2) +
  geom_bar(aes(pid3)) +
  facet_wrap(~cycle) 

ggplot(fec2) +
  geom_boxplot(aes(pid3, lncval)) +
  facet_wrap(~cycle) 

ggplot(fec2) +
  geom_bar(aes(pid3)) +
  facet_wrap(~cycle) 

table(fec2$con)

#amounts by year
ggplot(fec) +
  geom_smooth(aes(two_year_transaction_period, contribution_receipt_amount, color=party_id))



ggplot(fec) +
  geom_point(aes(two_year_transaction_period, contribution_receipt_amount, color=party_id))

#very interstesting if filtered down to the two major parties
#contributor aggregate not available for older years
ggplot(fec, aes(as.numeric(contribution_receipt_date), contribution_receipt_amount, color=pid)) +
  geom_smooth()

ggplot(fec2, aes(as.numeric(contribution_receipt_date), contribution_receipt_amount, color=pid3)) +
  geom_smooth()
lims <- as.POSIXct(c(1984, 2016))

#Good plot
lims <- c(as.POSIXct(as.Date("1982/01/02")), NA)
ggplot(fec2, aes(contribution_receipt_date, contribution_receipt_amount, color=pid3)) +
  geom_smooth() + 
  scale_x_datetime(date_labels = "%Y", date_breaks = "4 year", limits = lims)

ggplot(fec2, aes(as.numeric(contribution_receipt_date), lncval, color=pid3)) +
  geom_hex(alpha=0.2) +
  geom_smooth() 

ggplot(fec, aes(as.numeric(contribution_receipt_date), contribution_receipt_amount)) +
  geom_point() + 
  geom_smooth()



ggplot(fec, aes(two_year_transaction_period, contributor_aggregate_ytd, color=party_id)) +
  geom_point() + 
  geom_smooth()



ggplot(fec, aes(party_id, contributor_aggregate_ytd)) +
  geom_point() + 
  facet_grid(~ two_year_transaction_period)





test <- fec %>% 
  select(contributor_employer) %>% 
  unique()

test
+
#   geom_smooth(mapping = aes(year, salary), method="lm") +
#   xlab("Age") + 
#   ylab("Salary in $1,000's") +
#   ggtitle("Executive Salary by Age and Gender") +
#   theme(plot.title = element_text(hjust = 0.5)) 

  
  # ggplot(execs) +
  #   geom_point(aes(year, salary, color=gender), alpha = 0.25) +
  #   geom_smooth(mapping = aes(year, salary), method="lm") +
  #   xlab("Age") + 
#   ylab("Salary in $1,000's") +
#   ggtitle("Executive Salary by Age and Gender") +
#   theme(plot.title = element_text(hjust = 0.5)) 
