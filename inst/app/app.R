library(shiny)
library(bootsum) # Jouw eigen package!

# 1. Gebruikersinterface (Wat de bezoeker ziet)
ui <- fluidPage(
    titlePanel("Schatting totale massa gebaseerd op postensteekproef"),

    sidebarLayout(
        sidebarPanel(
            helpText("Upload een CSV-bestand met je steekproef. De app gaat ervan uit dat SOLL-bedragen (de juiste, eventueel gecorrigeerde, bedragen dus)in de eerste kolom staan."),

            fileInput("file_input", "Upload CSV-bestand:",
                      accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv"),
                      buttonLabel = "Bladeren...", placeholder = "Geen bestand geselecteerd"),

            radioButtons("sep", "Scheidingsteken in CSV:",
                         choices = c("Puntkomma (;)" = ";", "Komma (,)" = ","),
                         selected = ";"),

            tags$hr(), # Visueel scheidingslijntje

            numericInput("N_input", "Totaal aantal posten in de massa waaruit wordt gestoken (N):",
                         value = 1500, min = 1),

            sliderInput("zekerheid", "Gewenste zekerheid:",
                        min = 0.80, max = 0.99, value = 0.95, step = 0.01),

            numericInput("b_input", "Aantal bootstrap iteraties (b):",
                         value = 100000, min = 100, step = 1000),

            actionButton("calc", "Bereken Grenzen", class = "btn-primary", width = "100%")
        ),

        mainPanel(
            # Een klein tekstje dat laat zien hoeveel regels er succesvol zijn ingelezen
            textOutput("data_status"),
            br(),
            plotOutput("bootPlot", height = "500px")
        )
    )
)

# 2. Server (De motor onder de motorkap)
server <- function(input, output) {

    # Luister naar de bereken-knop en lees het bestand in
    v_data <- eventReactive(input$calc, {

        # Zorg dat de code stopt/wacht als er nog geen bestand is geüpload
        req(input$file_input)

        # Bepaal het decimaalteken op basis van het gekozen scheidingsteken
        dec_char <- ifelse(input$sep == ";", ",", ".")

        # Lees het CSV-bestand in
        df <- read.csv(input$file_input$datapath,
                       sep = input$sep,
                       dec = dec_char,
                       header = TRUE)

        # Pak de allereerste kolom uit het bestand en maak er getallen van
        v_num <- as.numeric(df[[1]])

        # Filter lege vakjes (NA) en onmogelijke bedragen weg
        v_num[!is.na(v_num) & v_num > 0]
    }, ignoreNULL = FALSE)

    # Laat even zien hoeveel geldige regels er zijn ingelezen
    output$data_status <- renderText({
        req(v_data())
        paste("✅ Bestand succesvol ingelezen! Aantal geldige steekproef-items:", length(v_data()))
    })

    # Genereer de grafiek
    output$bootPlot <- renderPlot({
        req(length(v_data()) > 0)

        # NIEUW: Hier is de hardcoded 10000 vervangen door 'input$b_input'
        bootsum(v = v_data(),
                N = input$N_input,
                zekerheid = input$zekerheid,
                b = input$b_input)
    })
}

# 3. Start de applicatie
shinyApp(ui = ui, server = server)
