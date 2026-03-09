# Visualisatie van de geschatte totale waarde van een massa financiële posten

Berekent en visualiseert BCa betrouwbaarheidsintervallen voor de totale
populatiewaarde op basis van een steekproef, met behulp van
bootstrapping.

## Usage

``` r
bootsum(v, N, certainty = 0.95, b = 1e+05)
```

## Arguments

- v:

  Een numerieke vector van positieve waarden (de getrokken steekproef).

- N:

  Integer. Het totale aantal posten in de massa (populatie) waaruit
  getrokken is.

- certainty:

  Numeric. Het zekerheidspercentage voor de minimum- en maximumgrens
  (standaard: 0.95).

- b:

  Integer. Het aantal bootstrap iteraties (standaard: 100.000).

## Value

Een lijst met de geobserveerde schatting, en de minimum- en maximumgrens
(invisibly).
