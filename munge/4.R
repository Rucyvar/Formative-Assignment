plot_yearly <- function(ds) {
  df <- ncd_summaries %>% filter(.dataset == ds)
  if (!nrow(df)) return(NULL)
  k <- get_keys(df); yr <- k$year
  if (is.na(yr)) return(ggplot() + ggtitle(paste(ds,"— no 'year' column")))
  metric <- select_best_metric(df, ds, exclude = yr)
  if (is.null(metric)) return(ggplot()+ggtitle(paste(ds,"— no usable metric")))
  df_sum <- df %>% group_by(.data[[yr]]) %>%
    summarise(total = sum(.data[[metric]], na.rm = TRUE), .groups = "drop")
  ggplot(df_sum, aes(x = as.integer(.data[[yr]]), y = total)) +
    geom_line() + geom_point() +
    labs(title = paste0(ds, ": total of ", metric, " by year"),
         x = "Year", y = paste("Sum of", metric)) +
    theme_minimal()
}
walk(datasets, ~{ p <- plot_yearly(.x); if(!is.null(p)) print(p) })


plot_top_countries <- function(ds, top_n = 10){
  df <- ncd_summaries %>% filter(.dataset == ds)
  if (!nrow(df)) return(NULL)
  k <- get_keys(df); yr <- k$year; id <- k$id
  if (any(is.na(c(yr,id)))) return(ggplot()+ggtitle(paste(ds,"— need year & country/iso/id")))
  metric <- select_best_metric(df, ds, exclude = yr)
  if (is.null(metric)) return(ggplot()+ggtitle(paste(ds,"— no usable metric")))
  latest <- suppressWarnings(max(df[[yr]], na.rm = TRUE))
  tab <- df %>% filter(.data[[yr]] == latest) %>%
    select(all_of(c(id, metric))) %>%
    arrange(desc(.data[[metric]])) %>% slice_head(n = top_n)
  ggplot(tab, aes(x = reorder(.data[[id]], .data[[metric]]), y = .data[[metric]])) +
    geom_col() + coord_flip() +
    labs(title = paste0(ds, ": top ", top_n, " in ", latest, " (", metric, ")"),
         x = id, y = metric) +
    theme_minimal()
}
walk(datasets, ~{ p <- plot_top_countries(.x); if(!is.null(p)) print(p) })