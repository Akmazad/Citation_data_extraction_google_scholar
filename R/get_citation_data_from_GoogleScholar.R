library(scholar)
library(dplyr)

# id of Pietro Lio
id <- '3YrWf7EAAAAJ'
l <- get_profile(id)
publist_full <- get_publications(id) %>%
  dplyr::filter(journal != '' &
                  number != '' &
                  !is.na(journal) &
                  !grepl(pattern = 'rXiv|Rxiv|Conference|Workshop|Proceedings', journal, fixed = F)) %>%
  dplyr::arrange(desc(year))
impact <- publist_full$journal %>% get_impactfactor(max.distance = 0.1)
publist_full %>% dplyr::select(journal) %>% dplyr::distinct()
