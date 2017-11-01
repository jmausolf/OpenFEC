library(tidyverse)

fec <- read_csv("Exxon_Mobile__merged_deduped_ANALYSIS_cleaned.csv")

ggplot(fec) +
   geom_bar(aes(party_id, color=employer_clean)) 

ggplot(fec) +
  geom_bar(aes(party_id, color=contributor_occupation)) 


#intersting, seems to be divide between executives and others
ggplot(fec) +
  geom_bar(aes(party_id)) +
  facet_wrap(~contributor_occupation)



#amounts by year
ggplot(fec) +
  geom_smooth(aes(two_year_transaction_period, contribution_receipt_amount, color=party_id))



ggplot(fec) +
  geom_point(aes(two_year_transaction_period, contribution_receipt_amount, color=party_id))


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
