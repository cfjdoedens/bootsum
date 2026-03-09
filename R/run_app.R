#' Start de Bootsum Shiny Applicatie
#'
#' Deze functie opent een interactieve webapplicatie in je browser
#' om steekproeven te evalueren met de bootsum methode.
#'
#' @export
run_bootsum_app <- function() {
  # Zoek waar de app precies is geïnstalleerd op de computer van de gebruiker
  app_dir <- system.file("app", package = "bootsum")

  # Beveiliging voor als er iets mis is gegaan bij de installatie
  if (app_dir == "") {
    stop("Kan de app niet vinden. Probeer het package 'bootsum' opnieuw te installeren.", call. = FALSE)
  }

  # Start de app
  shiny::runApp(app_dir, display.mode = "normal")
}
