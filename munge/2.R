# Combine all dataset summaries into one data frame
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