set.seed(1234)
library(dplyr)
library(data.table)
library(readxl)

source("R/get_citation_data_from_GoogleScholar.R")
outdir = "data/imamu_cs_all/"
dir.create(outdir)

# get a list of scholar ids
idList = fread("data/imamu_cs_gs_IDs.txt", header = F) %>%
  dplyr::select(1) %>%
  dplyr::rename("gs_id" = V1)

# full_db_cs = tibble()
# for(i in 1: length(idList$gs_id)){
#   gsid = idList$gs_id[i]
#   full_db_cs <- full_db_cs %>%
#     dplyr::bind_rows(GSID_2_formated_publications(id = gsid))
#   print(paste0("(", i, ") ", gsid, " [DONE]"))
# }
#
# full_db_cs %>%
#   fwrite(file = paste0(outdir, "all_IMAMU_cs_all_pubs.csv"))

con <- file(paste0(outdir,"logs.log"))
sink(con, append=TRUE)
sink(con, append=TRUE, type="message")
for(i in 1: length(idList$gs_id)){
  gsid = idList$gs_id[i]



  p <- GSID_2_formated_publications(id = gsid)
  if(!p %>% nrow %>% is.null){
    p %>%
      fwrite(file = paste0(outdir, gsid, ".csv"))
    print(paste0("(", i, ") ", gsid, " [DONE]"))
  }else
    message("No publications found for the id: ", gsid)
}

sink()
sink(type="message")
