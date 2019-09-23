## @knitr results
filenames <- c("result_2.csv", "result_1.csv") %>%
map_chr(~file.path("data", .))

col_names <- filenames[1] %>%
read_csv(col_types = "cdddd", n_max=0) %>%
names

data <- filenames %>%
map_df(read_csv, col_types = "cdddd", col_names = col_names, skip = 2, .id="sub") %>%
mutate_at("sub", factor, labels=c("sub1", "sub2")) %>%
mutate_at("peak", factor) %>%
group_by(sub, peak, stable_rel)

data_agg <- data %>%
summarize(
  pitch_mean = mean(pitch_Hz),
  pitch_sem = sd(pitch_Hz)/sqrt(n()),
  lower = pitch_mean - 2*pitch_sem,
  upper = pitch_mean + 2*pitch_sem
)

data_agg %>%
ggplot(
  aes(x=stable_rel, y=pitch_mean, colour=peak)
) + geom_point(
) + geom_errorbar(
  aes(ymin=lower, ymax=upper)
) + labs(
  x = "Relativer Anteil stabiler Frequenz innerhalb einer Modulationsperiode",
  y = "durchschnittlich eingestellte Tonhöhe in Hz",
  colour = "Richtung der Peaks einer Modulation",
  fill = "Teilnehmer"
) + scale_x_continuous(
  labels = scales::percent
) + facet_grid(
  sub~.
)
