library(shiny)
library(RMySQL)
library(shinythemes)
library(ECharts2Shiny)
library(ggplot2)
library(plotly)
library(dplyr)

# Mysql database connection
mysqlconnection = dbConnect(RMySQL::MySQL(),
                            dbname='cars',
                            host='localhost',
                            port=3306,
                            user='Kacper',
                            password='Passw0rd')

brand = fetch(dbSendQuery(mysqlconnection, "select brand from sale_2018"))
model = fetch(dbSendQuery(mysqlconnection, "select model from sale_2018"))
sold = fetch(dbSendQuery(mysqlconnection, "select amountSold from sale_2018"))

# Data preparation
dfall <- data.frame(brand,model,sold)
colnames(dfall) <- c("Brand","Model","Amount sold")
soldByBrand <- dfall %>% group_by(Brand) %>% summarise(Total = sum(`Amount sold`))
numberOfBrands <- data.frame(table(dfall$Brand))
dat2 <- data.frame(numberOfBrands[,2],soldByBrand[,2])
colnames(dat2) <- c("Number of models sold","Units sold")
row.names(dat2) <- soldByBrand$Brand


# UI layout -------------------------------------------------
ui <- fluidPage(theme = shinytheme("cerulean"),
                navbarPage("Menu: ",
                           tabPanel("Introduction",htmlOutput("introduction"),icon=icon("info-circle")),
                           tabPanel("Data set",DT::dataTableOutput("dataSet"),icon=icon("database")),
                           navbarMenu("Charts",icon=icon("chart-bar"),
                                      tabPanel("Number of models and units sold",fluidPage(
                                                 loadEChartsLibrary(),
                                                 tags$div(id="test", style="width:80%;height:800px"),
                                                 deliverChart(div_id = "test"))),
                                      tabPanel("Most frequently purchased models",plotlyOutput("buble")),
                                      tabPanel("Discrepancy of units sold",plotlyOutput("normal"))),
                           tabPanel("Summary",verbatimTextOutput("summary"),htmlOutput("summary2"),icon=icon("clipboard")),
                           tags$style(type = 'text/css', '.navbar {
                           font-family: Arial;
                           font-size: 20px;}', '.dropdown-menu {
                           font-family: Arial;
                           font-size: 22px;}')
                           ))


# Server function -------------------------------------------
server <- function(input, output, session) {
  output$introduction <- renderText({
    paste("<font size=\"28\" color=\"#1E90FF\"><b>Most purchased cars in Poland in 2018</b></font>","<br>
            <font size=\"6\">Performed by: smok313-zdr <a href=\"https://github.com/smok313-zdr\">https://github.com/smok313-zdr</a><br>
            <br>Source:<br><a href=\"http://moto.pl/MotoPL/7,88389,24331315,
            najczesciej-kupowane-samochody-w-2018-roku-w-polsce-jest-zmiana.html\">http://moto.pl/MotoPL/7,88389,24331315,najczesciej-
            kupowane-samochody-w-2018-roku-w-polsce-jest-zmiana.html</a><br><br>This is a list of the 30 most frequently purchased car 
            brands, models and the number of units sold.</font><br><br><img src=\"skoda.jpg\" width=\"60%\" height=\"50%\">")
  })
  output$dataSet <- DT::renderDataTable({
    DT::datatable(dfall, options = list(pageLength = 30))
  })
  renderBarChart(div_id = "test", grid_left = '1%', direction = "horizontal", data = dat2,font.size.axis.x = 14, font.size.axis.y = 14,font.size.legend = 18)

  session$onSessionEnded(function(){
    dbDisconnect(mysqlconnection)
  })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
