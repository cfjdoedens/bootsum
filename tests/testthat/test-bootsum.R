test_that("bootsum werkt en geeft correcte lijst terug", {
  v <- c(10, 20, 30, 40, 50)
  N <- 1000 # Fictieve populatiegrootte

  pdf(NULL)
  # Voor de stabiliteit van de test zetten we b op 500
  result <- bootsum(v, N = N, b = 500)
  dev.off()

  # Check of het een lijst is
  expect_type(result, "list")

  # Check of exact deze 3 elementen erin zitten
  expect_named(result, c("obs_est", "min_bound", "max_bound"))

  # Check of de geobserveerde schatting wiskundig klopt (mean(v) * N)
  expect_equal(result$obs_est, mean(v) * N)

  # Check of de grenzen logisch zijn (minimum is kleiner dan of gelijk aan maximum)
  expect_true(result$min_bound <= result$max_bound)
})

test_that("bootsum geeft correcte errors bij ongeldige input", {
  v <- c(10, 20, 30, 40, 50)

  pdf(NULL)

  # Fout: N ontbreekt
  expect_error(bootsum(v), "'N' moet worden opgegeven")

  # Fout: N is kleiner dan het aantal getrokken posten (5)
  expect_error(bootsum(v, N = 3), "groter zijn dan of gelijk aan het aantal getrokken posten")

  # Fout: v bevat een negatief getal of nul
  expect_error(bootsum(c(10, 20, -5), N = 100), "mag alleen positieve getallen bevatten")

  dev.off()
})

test_that("bootsum geeft logische grenzen bij normaal verdeelde data", {
  # Zet een vaste seed voor reproduceerbare tests
  set.seed(42)

  # Genereer 100 positieve, normaal verdeelde getallen (gemiddelde = 100, standaardafwijking = 5)
  v_norm <- rnorm(100, mean = 100, sd = 5)
  N <- 10000 # Populatiegrootte

  pdf(NULL)
  # Gebruik b=1000 voor voldoende precisie
  result <- bootsum(v_norm, N = N, b = 1000)
  dev.off()

  # 1. De schatting moet exact mean(v_norm) * N zijn
  expect_equal(result$obs_est, mean(v_norm) * N)

  # 2. De schatting MOET netjes tussen het minimum en maximum liggen
  expect_true(result$obs_est > result$min_bound)
  expect_true(result$obs_est < result$max_bound)
})
