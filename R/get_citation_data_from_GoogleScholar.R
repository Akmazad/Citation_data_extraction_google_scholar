extract_google_scholar <- function(id='3YrWf7EAAAAJ', delay = 0.4){

  library(scholar)
  library(dplyr)

  make_delay_between_googleReq(delay)

  publist_full = get_publications(id)
  if(! publist_full %>% nrow %>% is.null){
    publist_full <-  publist_full %>%
      dplyr::filter(journal != '' &
                      number != '' &
                      !is.na(journal) &
                      !grepl(pattern = 'rXiv|Rxiv|Conference|Workshop|Proceedings|PREPRINTS|Preprints|Book', title, fixed = F) &
                      !grepl(pattern = 'rXiv|Rxiv|Conference|Workshop|Proceedings|PREPRINTS|Preprints|Book', journal, fixed = F) &
                      !grepl(pattern = 'rXiv|Rxiv|Conference|Workshop|Proceedings|PREPRINTS|Preprints|Book', number, fixed = F)) %>%
      dplyr::arrange(desc(year))

    current_year = as.integer(format(Sys.Date(), "%Y"))
    if(! current_year %in% publist_full$year)
      message(paste0(id, " doesn't have publicatios for the current year: ", current_year))
  }
  return(publist_full)

}

make_delay_between_googleReq <- function(delay){

  min_delay = delay - .5
  max_delay = delay + .5
  if(min_delay < 0) min_delay <- 0
  if(delay == 0) max_delay <- 0

  delay <- sample(seq(min_delay, max_delay, by = .001), 1)
  Sys.sleep(delay)
}

GSID_2_formated_publications <- function(id){
  library(dplyr)

  p <- extract_google_scholar(id = id)
  if(! p %>% nrow %>% is.null){
    p <- p %>%
      dplyr::mutate("Publication (journal name. volume, no. pages)" = paste(journal, number)) %>%
      dplyr::mutate(Cited_by = paste0("https://scholar.google.com/scholar?oi=bibs&hl=en&cites=", cid)) %>%
      dplyr::mutate(Link = dplyr::if_else(cites == 0, "", paste0(
        "https://scholar.google.com/citations?view_op=view_citation&hl=en&user=",id,
        "&pagesize=100&sortby=pubdate&citation_for_view=", id, ":",pubid
      ))) %>%
      dplyr::bind_cols("Scholar ID" = id) %>%
      dplyr::relocate(`Scholar ID`) %>%
      dplyr::rename("Paper Title" = title,
                    "Authors" = author,
                    "Year" = year)

    if(nrow(p) > 0){
      p <- p %>%
        dplyr::mutate("Paper Number" = 1:nrow(p)) %>%
        dplyr::select(c(`Scholar ID`, `Paper Number`, `Paper Title`, Authors,
                        `Publication (journal name. volume, no. pages)`,
                        Year, Cited_by, Link))
    }
  }
  return(p)
}

export_article_df_to_referenceStyle <- function(df, path="./data/"){
  library(officer)
  library(flextable)
  library(magrittr)
  references <-  paste0(df$author, ". ",
                        df$title, ". ",
                        "***", df$journal, "***", ", ",
                        df$number, ", ",
                        df$year) %>%
    as.data.frame()

  references %>% fwrite(file = paste0(path,"doc.csv"))

}

read_JCR_file <- function(filepath="./data/latestJCRlist2022.xlsx"){
  library(readxl)

  readxl::read_xlsx(filepath) %>%
    dplyr::select(c("journal_name","if_2022")) %>%
    dplyr::rename("journal"=journal_name,
                  "ImpactFactor" = if_2022) %>%
    dplyr::mutate(journal = journal %>% toupper(),
                  ImpactFactor = ImpactFactor %>% as.numeric()) %>%
    return()
}
