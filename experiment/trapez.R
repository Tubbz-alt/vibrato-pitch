# Trapeze plotten für die Präsentation
## @knitr trapez
trapez <- read_csv("experiment/trapez.csv", col_names = c("l0", "l25", "h25", "l5", "h5", "l75", "h75"), col_types = "ddddddd")
trapez <- tidyr::gather(trapez, "type", "freq")
ggplot(
  trapez,
  aes(y = freq)
) + labs(
  x = "Sample",
  y = "Frequenz in Hz"
) + facet_grid(type~.)