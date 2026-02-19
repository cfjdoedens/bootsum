#' Visualisatie van de geschatte totale waarde van een massa financiële posten
#'
#' Berekent en visualiseert BCa betrouwbaarheidsintervallen voor de totale
#' populatiewaarde op basis van een steekproef, met behulp van bootstrapping.
#'
#' @param v Een numerieke vector van positieve waarden (de getrokken steekproef).
#' @param N Integer. Het totale aantal posten in de massa (populatie) waaruit getrokken is.
#' @param certainty Numeric. Het zekerheidspercentage voor de minimum- en maximumgrens (standaard: 0.95).
#' @param b Integer. Het aantal bootstrap iteraties (standaard: 100.000).
#'
#' @return Een lijst met de geobserveerde schatting, en de minimum- en maximumgrens (invisibly).
#' @importFrom boot boot boot.ci
#' @importFrom graphics hist abline legend axis par
#' @export
bootsum <- function(v, N, certainty = 0.95, b = 100000) {

  # 1. Validatie
  if (!is.numeric(v) || any(v <= 0)) {
    stop("Vector 'v' mag alleen positieve getallen bevatten.")
  }
  n <- length(v)
  if (missing(N) || !is.numeric(N) || N < n) {
    stop("'N' moet worden opgegeven en moet groter zijn dan of gelijk aan het aantal getrokken posten in 'v'.")
  }
  if (!requireNamespace("boot", quietly = TRUE)) {
    stop("Het 'boot' package is nodig. Installeer dit met install.packages('boot').")
  }

  # Hulpfuncties: Formatteren in Nederlandse notatie
  fmt_num <- function(x) {
    format(round(x, 0), big.mark = ".", decimal.mark = ",", scientific = FALSE, trim = TRUE)
  }
  fmt_pct <- function(x) {
    format(round(x, 1), decimal.mark = ",", scientific = FALSE, trim = TRUE)
  }

  # 2. Bereken Geschatte Totale Waarde van de Massa
  obs_est <- mean(v) * N

  # 3. Voer Bootstrap uit
  sum_fn <- function(data, indices) {
    return(mean(data[indices]) * N)
  }

  boot_result <- boot::boot(data = v, statistic = sum_fn, R = b)
  boot_ests <- as.vector(boot_result$t)

  # 4. Bereken BCa Grenzen (Ieder met 'certainty' zekerheid)
  #    Wiskundig knippen we aan beide kanten de juiste foutmarge af.
  alpha <- 1 - certainty
  conf_proxy <- 1 - (2 * alpha)

  ci_obj <- tryCatch({
    boot::boot.ci(boot_result, conf = conf_proxy, type = "bca")
  }, error = function(e) stop("BCa berekening mislukt (te weinig variantie)."))

  bounds <- c(ci_obj$bca[4], ci_obj$bca[5])

  # 5. Bereken Percentages t.o.v. schatting
  pct_val <- (bounds / obs_est) * 100

  # 6. Maak Dynamische Titel
  conf_pct_str <- fmt_pct(certainty * 100)

  plot_title <- sprintf(
    "Bootstrap Geschatte Totale Waarde (BCa)\nSchatting: %s\nMinimum en maximum (ieder met %s%% zekerheid):\nMin %s (%s%%)  |  Max %s (%s%%)",
    fmt_num(obs_est),
    conf_pct_str,
    fmt_num(bounds[1]), fmt_pct(pct_val[1]),
    fmt_num(bounds[2]), fmt_pct(pct_val[2])
  )

  # 7. Plot Histogram
  old_par <- par(mar = c(5, 4, 6, 2) + 0.1)

  h <- graphics::hist(boot_ests,
                      main = plot_title,
                      xlab = sprintf("Geschatte totale waarde (N = %s)", fmt_num(N)),
                      col = "#69b3a2",
                      border = "white",
                      breaks = 50,
                      cex.main = 0.9,
                      xaxt = "n")

  # 8. Teken handmatig de X-as
  graphics::axis(1, at = pretty(boot_ests), labels = fmt_num(pretty(boot_ests)))

  # 9. Lijnen Toevoegen (Schatting rood, Min/Max blauw gestreept)
  graphics::abline(v = obs_est, col = "red", lwd = 3)
  graphics::abline(v = bounds, col = "blue", lwd = 2, lty = 2)

  # 10. Legenda
  leg_bounds <- sprintf("Min / Max (%s%% zekerheid)", conf_pct_str)

  graphics::legend("topright",
                   legend = c("Schatting", leg_bounds),
                   col = c("red", "blue"),
                   lwd = c(3, 2),
                   lty = c(1, 2),
                   cex = 0.8,
                   bg = "white")

  par(old_par)

  # Return de opgeschoonde namen in de lijst
  invisible(list(
    obs_est = obs_est,
    min_bound = bounds[1],
    max_bound = bounds[2]
  ))
}
