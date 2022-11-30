library(shiny)
library(RMySQL)

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

# UI layout -------------------------------------------------
ui <- fluidPage(

    
)

# Server function -------------------------------------------
server <- function(input, output) {

    
}

# Run the application 
shinyApp(ui = ui, server = server)
