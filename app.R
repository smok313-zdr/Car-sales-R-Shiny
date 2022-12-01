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
summaryData <- data.frame(soldByBrand$Brand,dat2)
colnames(summaryData) <- c("Brand","Number of models sold","Units sold")
row.names(summaryData) <- c(1:13)

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

  output$buble <- renderPlotly({
    q <- ggplot(dfall, aes(x=Model, y=Brand, size=`Amount sold`),guide=FALSE)+ggtitle("Most purchased car models in 2018 in Poland")+
      geom_point(colour="white", fill="red", shape=21)+ scale_size_area(max_size = 15)+
      theme_bw() + theme(axis.text.x = element_text(angle = 90),text = element_text(size=15)) 
    ggplotly(q, width = 1200, height = 800)
  })
  
  output$normal <- renderPlotly({
    dfall$`model` <- dfall$Model 
    dfall$normalizacja <- round((dfall$`Amount sold` - mean(dfall$`Amount sold`))/sd(dfall$`Amount sold`), 2) 
    dfall$type <- ifelse(dfall$normalizacja < 0, "Below average", "Above average")  
    dfall <- dfall[order(dfall$normalizacja), ]  
    dfall$`model` <- factor(dfall$`model`, levels = dfall$`model`)  
    q2 <- ggplot(dfall, aes(x=`model`, y=normalizacja, label=normalizacja)) + 
      geom_bar(stat='identity', aes(fill=type), width=.5)  + ylab("Standardization") +
      scale_fill_manual(name="\nSales in 2018", 
                        labels = c("Above average", "Below average"), 
                        values = c("Above average"="#00ba38", "Below average"="#f8766d")) + 
      labs(title= "Discrepancy of units sold",subtitle="Standardized car sales") + coord_flip() + theme(text = element_text(size=15)) 
    ggplotly(q2, width = 1200, height = 800)
  })
  
  output$summary <- renderPrint({
    summary(summaryData,maxsum = 13)
  })
  
  output$summary2 <- renderText({
    invalidateLater(1000, session)
    paste("<br><font size=\"11\">The year 2018, in terms of the largest number of cars sold in Poland, definitely belonged to Skoda.
            Toyota came in second and Volkswagen in third place. The most popular car models that Poles chose were: 
            Skoda Octavia, Skoda Fabia and Opel Astra. Our list of the 30 most popular cars bought in 2018 is closed by the Volvo brand 
            with the lowest number of units sold.<br><br>Current time: ", Sys.time(),"</font>")
  })
  
  session$onSessionEnded(function(){
    dbDisconnect(mysqlconnection)
  })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
