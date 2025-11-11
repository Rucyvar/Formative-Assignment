suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(purrr)
})

# helper: find the first column whose name matches any of the given regexes (case-insensitive)
find_col <- function(nms, patterns) {
  ix <- which(sapply(patterns, function(p) any(grepl(p, nms, ignore.case = TRUE))))
  if (length(ix) == 0) return(NULL)
  for (p in patterns) {
    hit <- nms[grepl(p, nms, ignore.case = TRUE)]
    if (length(hit)) return(hit[[1]])
  }
  NULL
}

# summariser that NEVER renames original columns; it only *selects* them by detected names.
# It returns a tidy summary of means for all numeric columns by available keys.
summarise_any_dataset <- function(df, dataset_name) {
  stopifnot(is.data.frame(df))
  
  nms <- names(df)
  
  # Detect keys by pattern (no renaming):
  col_year    <- find_col(nms, c("^year$", "year\\b"))
  col_sex     <- find_col(nms, c("^sex$", "sex\\b", "gender\\b"))
  col_country <- find_col(nms, c("^country$", "country\\b", "name\\b", "location\\b", "nation\\b"))
  col_iso3    <- find_col(nms, c("^iso3$", "iso\\b", "code\\b"))
  
  # Pick grouping variables that actually exist:
  grp <- c(col_year, col_sex, col_country, col_iso3) %>% discard(is.null) %>% unique()
  
  # Identify numeric value columns to summarise (exclude grouping cols)
  num_cols <- df %>%
    select(where(is.numeric)) %>%
    select(-any_of(grp)) %>%
    names()
  
  if (length(num_cols) == 0) {
    return(tibble(
      .dataset = dataset_name,
      .note = "No numeric value columns detected; nothing to summarise."
    ))
  }
  
  out <-
    df %>%
    group_by(across(all_of(grp)), .add = FALSE) %>%
    summarise(across(all_of(num_cols), ~ mean(.x, na.rm = TRUE), .names = "{.col}"),
              .groups = "drop") %>%
    mutate(.dataset = dataset_name,
           .keys = paste(grp, collapse = "|"))
  
  out
}

safe_summarise <- purrr::safely(summarise_any_dataset, otherwise = NULL)

# List of expected object names (derived from your filenames)
datasets <- list(
  BMI_adult      = "NCD_RisC_Lancet_2024_BMI_age_standardised_country",
  BMI_child_ado  = "NCD_RisC_Lancet_2024_BMI_child_adolescent_country_ageStd",
  BP             = "NCD_RisC_Lancet_2017_BP_age_standardised_countries",
  Diabetes       = "NCD_RisC_Lancet_2024_Diabetes_age_standardised_countries",
  Cholesterol    = "NCD_RisC_Nature_2020_Cholesterol_age_standardised_countries"
)

available <- ls(envir = .GlobalEnv)

summary_list <- list()

for (nick in names(datasets)) {
  obj_name <- datasets[[nick]]
  if (obj_name %in% available) {
    df <- get(obj_name, envir = .GlobalEnv)
    res <- safe_summarise(df, nick)
    if (!is.null(res$result)) {
      summary_list[[nick]] <- res$result
    } else {
      summary_list[[nick]] <- tibble(.dataset = nick,
                                     .note = paste("Could not summarise:", res$error$message))
    }
  } else {
    summary_list[[nick]] <- tibble(.dataset = nick,
                                   .note = paste0("Data frame '", obj_name, "' not found in environment."))
  }
}

ncd_summaries <- dplyr::bind_rows(summary_list)
cache("ncd_summaries")

detected_info <- ncd_summaries %>%
  dplyr::select(.dataset, .keys, dplyr::everything()) %>%
  dplyr::summarise(dplyr::across(where(is.numeric), ~ TRUE), .by = c(.dataset, .keys)) %>%
  tidyr::pivot_longer(-c(.dataset, .keys), names_to = "numeric_column", values_to = "detected") %>%
  dplyr::filter(detected) %>%
  dplyr::distinct()

cache("detected_info")

raw_objects_present <- intersect(available, unname(unlist(datasets)))
cache("raw_objects_present")


#Combine all dataset summaries into one data frame
ncd_summaries <- bind_rows(summary_list)

# Detect numeric columns across datasets
detected_info <- ncd_summaries %>%
  select(.dataset, .keys, everything()) %>%
  summarise(across(where(is.numeric), ~ TRUE), .by = c(.dataset, .keys)) %>%
  pivot_longer(
    cols = -c(.dataset, .keys),
    names_to = "numeric_column",
    values_to = "detected"
  ) %>%
  filter(detected) %>%
  distinct()

# (Optional) Save results into ProjectTemplate cache for autoloading next time
if (dir.exists("cache")) {
  saveRDS(ncd_summaries, "cache/ncd_summaries.rds")
  saveRDS(detected_info, "cache/detected_info.rds")
}
