library(dplyr); library(tidyr); library(ggplot2); library(purrr); library(stringr)

# find year + country-like id (country > location > iso3/code > name)
get_keys <- function(df) {
  nms <- names(df)
  year_col <- nms[grepl("^year$|\\byear\\b", nms, ignore.case = TRUE)][1]
  pick <- function(p) nms[grepl(p, nms, ignore.case = TRUE)][1]
  id_col <- pick("^country$"); if (is.na(id_col)) id_col <- pick("^location$")
  if (is.na(id_col)) id_col <- pick("^iso3$|^iso$|^code$")
  if (is.na(id_col)) {
    cand <- nms[grepl("name", nms, ignore.case = TRUE) &
                  !grepl("mean|median|max|min|sd|se|_name", nms, ignore.case = TRUE)]
    id_col <- cand[1]
  }
  sex_col <- nms[grepl("^sex$|\\bsex\\b|gender", nms, ignore.case = TRUE)][1]
  list(year = year_col, id = id_col, sex = sex_col)
}

# pick a sensible metric automatically (most complete, with variance; dataset-specific preference)
select_best_metric <- function(df, ds, exclude = character()) {
  num <- df %>% select(where(is.numeric)) %>% select(-any_of(exclude))
  if (!ncol(num)) return(NULL)
  nm <- names(num)
  prefs <- switch(
    ds,
    BP            = c("sbp|systolic|dbp|diastolic", "blood.?pressure", "mean"),
    Cholesterol   = c("chol|ldl|hdl|total", "mean"),
    Diabetes      = c("diab|fpg|glucose|prev|preval", "mean"),
    BMI_adult     = c("bmi|mean", "prev|preval"),
    BMI_child_ado = c("bmi|prev|preval", "mean"),
    c("bmi|sbp|dbp|chol|ldl|hdl|diab|prev|preval|mean")
  )
  stats <- map_dfr(nm, ~{
    v <- num[[.x]]
    tibble(col = .x, nn = sum(!is.na(v)), sdev = if (all(is.na(v))) 0 else sd(v, na.rm = TRUE))
  })
  pref_rank <- rep(Inf, length(nm))
  for (i in seq_along(prefs)) {
    hits <- grepl(prefs[i], nm, ignore.case = TRUE)
    pref_rank[hits] <- pmin(pref_rank[hits], i)
  }
  stats %>% mutate(pref = pref_rank) %>%
    arrange(pref, desc(nn), desc(sdev)) %>% slice(1) %>% pull(col)
}

datasets <- c("BMI_adult","BMI_child_ado","BP","Diabetes","Cholesterol")