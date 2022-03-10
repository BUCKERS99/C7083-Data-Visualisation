#### Header ####
## Statistical analysis for data science
## Assignment code for C7081
## Harry Buckley - 17239400
## last edited: 25/11/21


# CONTENTS ####
## 0.0 Setup ####



if(!require("shiny")) install.packages("shiny")
if(!require("bslib")) install.packages("bslib")
if(!require("plotly")) install.packages("plotly")
if(!require("tidyverse")) install.packages("tidyverse")
if(!require("shinydashboard")) install.packages("shiydashboard")
if(!require("shinythemes")) install.packages("shiythemes")
if(!require("dplyr")) install.packages("dplyr")
if(!require("ggplot2")) install.packages("ggplot2")
if(!require("ggthemes")) install.packages("ggthemes")
if(!require("gganimate")) install.packages("gganimate")
if(!require("extrafont")) install.packages("extrafont")
if(!require("kableExtra")) install.packages("kableExtra")



yield <-readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-01/key_crop_yields.csv') 

tracs <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-01/cereal_yields_vs_tractor_inputs_in_agriculture.csv')
use <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-01/land_use_vs_yield_change_in_cereal_production.csv')
land <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-01/arable_land_pin.csv')

# renaming variables
names(tracs)[names(tracs) == "Tractors per 100 sq km arable land"] <- "tractor"
names(tracs)[names(tracs) == "Cereal yield (kilograms per hectare) (kg per hectare)"] <- "Yield"
names(yield)[names(yield) == "Wheat (tonnes per hectare)" ] <- "Wheat"
names(yield)[names(yield) == "Rice (tonnes per hectare)" ] <- "Rice"
names(yield)[names(yield) == "Maize (tonnes per hectare)" ] <- "Maize"
names(yield)[names(yield) == "Soybeans (tonnes per hectare)" ] <- "Soybeans"
names(yield)[names(yield) == "Potatoes (tonnes per hectare)" ] <- "Potatoes"
names(yield)[names(yield) == "Beans (tonnes per hectare)" ] <- "Beans"
names(yield)[names(yield) == "Peas (tonnes per hectare)" ] <- "Peas"
names(yield)[names(yield) == "Cassava (tonnes per hectare)" ] <- "Cassava"
names(yield)[names(yield) == "Barley (tonnes per hectare)" ] <- "Barley"
names(yield)[names(yield) == "Cocoa beans (tonnes per hectare)" ] <- "Cocoa"
names(yield)[names(yield) == "Bananas (tonnes per hectare)" ] <- "Bananas"
names(land)[names(land) == "Arable land needed to produce a fixed quantity of crops ((1.0 = 1961))" ] <- "land requirement"
names(use)[names(use) == "Change to land area used for cereal production since 1961" ] <- "land change"

## 1.0 Shiny APP ####
yield <-readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-01/key_crop_yields.csv')

# library(shiny)
# library(shinythemes)
# install.packages("ggtextures")
# install.packages("ggtextures")
# install.packages("magick")
# library(ggtextures)
# library(magick)

# install.packages("remotes")
# remotes::install_github("coolbutuseless/ggpattern")
# install.packages("ggpattern")
# library(ggpattern)
#renaming
names(yield)[names(yield) == "Wheat (tonnes per hectare)" ] <- "Wheat"
names(yield)[names(yield) == "Rice (tonnes per hectare)" ] <- "Rice"
names(yield)[names(yield) == "Maize (tonnes per hectare)" ] <- "Maize"
names(yield)[names(yield) == "Soybeans (tonnes per hectare)" ] <- "Soybeans"
names(yield)[names(yield) == "Potatoes (tonnes per hectare)" ] <- "Potatoes"
names(yield)[names(yield) == "Beans (tonnes per hectare)" ] <- "Beans"
names(yield)[names(yield) == "Peas (tonnes per hectare)" ] <- "Peas"
names(yield)[names(yield) == "Cassava (tonnes per hectare)" ] <- "Cassava"
names(yield)[names(yield) == "Barley (tonnes per hectare)" ] <- "Barley"
names(yield)[names(yield) == "Cocoa beans (tonnes per hectare)" ] <- "Cocoa"
names(yield)[names(yield) == "Bananas (tonnes per hectare)" ] <- "Bananas"


# Data manipulation
yield.shiny <- yield %>%
  pivot_longer(cols = starts_with(c("Wheat", "Rice", "Maize", "Soybeans", "Potatoes", "Beans",
                                    "Peas", "Cassava", "Barley", "Cocoa", "Bananas")),
               names_to = "Commodity",
               values_to = "tonnes_per_hectare") %>%
  group_by(Year)

# Set up
commodity_colors <- c('#ffe119',
                      '#e6194b', 
                      '#3cb44b', 
                      '#4363d8', 
                      '#f58231', 
                      '#911eb4', 
                      '#46f0f0', 
                      '#f032e6', 
                      '#bcf60c', 
                      '#fabebe',
                      '#808000') 


Commodity_Names <- c("Wheat", "Rice", "Maize", "Soybeans", "Potatoes", "Beans",
                     "Peas", "Cassava", "Barley", "Cocoa", "Bananas")




# Creating the UI and Server

ui <- fluidPage(
  theme = shinytheme("united"),
  titlePanel("Which countries grow what crop?"),
  fluidRow(
    column(10, "Start typing the country name")),
  fluidRow(
    column(6,
           selectizeInput(inputId = "Country1",
                          label = "Type the country:",
                          choices = NULL),
           multiple = F),
    column(6, 
           selectizeInput( inputId = "Country2",
                           label = "Type the Country:",
                           choices = NULL),
           multiple = F)),
  fluidRow(
    column(6,
           selectizeInput(inputId = "Year1",
                          label = "Type the year:",
                          choices = NULL),
           multiple = F),
    column(6, 
           selectizeInput( inputId = "Year2",
                           label = "Type the year:",
                           choices = NULL),
           multiple = F)),
  
  fluidRow(
    column(width = 6, 
           h1(textOutput(outputId = "text1"), align = "Center"),
           plotOutput(outputId = "plot1")), 
    
    column(width = 6, 
           h1(textOutput(outputId = "text2"), align = "Center"),
           plotOutput(outputId = "plot2")))
)


server <- function(input, output) {
  updateSelectizeInput(session = getDefaultReactiveDomain(), "Country1",
                       choices = sort(yield.shiny$Entity),
                       selected = "Colombia"[1],
                       server = T)
  updateSelectizeInput(session = getDefaultReactiveDomain(), "Year1",
                       choices = sort(yield.shiny$Year),
                       selected = "1968"[1],
                       server = T)
  updateSelectizeInput(session = getDefaultReactiveDomain(), "Country2",
                       choices = sort(yield.shiny$Entity),
                       selected = "Colombia"[1],
                       server = T)
  updateSelectizeInput(session = getDefaultReactiveDomain(), "Year2",
                       choices = sort(yield.shiny$Year),
                       selected = "2018"[1],
                       server = T)
  
  output$text1 <- renderText({
    paste(input$Country1, " ", input$Year1)
  })
  output$plot1 <- renderPlot({
    ggplot(yield.shiny, aes(x = Commodity, y = tonnes_per_hectare, fill = Commodity)) +
      geom_col(data = yield.shiny[yield.shiny$Entity == input$Country1 & yield.shiny$Year == input$Year1, ]) +
      scale_color_manual( values = commodity_colors) +
      theme_classic() +
      theme(axis.text.x = element_text(angle = 90, size = 15, vjust = -.01), axis.ticks.x = element_blank(),
            legend.position = "none") +
      labs(y = "Tonnes per Hectare") 
    
  })
  
  output$text2 <- renderText({
    paste(input$Country2, " ", input$Year2)
  })
  output$plot2 <- renderPlot({
    ggplot(yield.shiny, aes(x = Commodity, y = tonnes_per_hectare, fill = Commodity)) +
      geom_col(data = yield.shiny[yield.shiny$Entity == input$Country2 & yield.shiny$Year == input$Year2, ]) +
      scale_color_manual( values = commodity_colors) +
      theme_classic() +
      theme(axis.text.x = element_text(angle = 90, size = 15, vjust = -.01), axis.ticks.x = element_blank(),
            legend.position = "none") +
      labs(y = "Tonnes per Hectare") 
    
  })
  
}

 shinyApp(ui, server)

## 2.0 Tractors GGPLOT ####

tracs <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-01/cereal_yields_vs_tractor_inputs_in_agriculture.csv')

# Rename some varibales
names(tracs)[names(tracs) == "Tractors per 100 sq km arable land"] <- "tractor"
names(tracs)[names(tracs) == "Cereal yield (kilograms per hectare) (kg per hectare)"] <- "Yield"

# factorise Entity
tracs$Entity <- as.factor(tracs$Entity)
tracs$Year <- as.numeric(tracs$Year)

#na removal
tracs.na <- na.omit(tracs) 
# filter years between 1990 and 2010
tracs.date <- tracs.na %>%
  filter(between(Year, 1990, 2010))
# # getting the mean number of tractors per year
#  tractor.mean <- tapply(tracs.date$tractor, INDEX = tracs.date$Year, FUN = mean)
#  # make this into a data frame
#  a <- c(1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000,
#         2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009)
# b <- c(329.2695, 333.9251, 355.9274, 361.6496, 372.9959, 379.5699, 388.3019, 411.0564, 434.6873, 459.7023, 479.4574, 558.8036,
#       602.3337, 576.0309, 578.6356, 598.0310, 346.6159, 366.0877, 283.9023, 426.0272) 
# 
# tractor.mean <- data.frame(Year = a, avg = b)
# Adding the avg values to the data frame depending on the year
tracs.date <-  tracs.date %>%
  dplyr::mutate(avg = 
                  case_when(Year == 1990 ~ "329",
                            Year == 1991 ~ "334",
                            Year == 1992 ~ "355",
                            Year == 1993 ~ "362",
                            Year == 1994 ~ "373",
                            Year == 1995 ~ "380",
                            Year == 1996 ~ "388",
                            Year == 1997 ~ "411",
                            Year == 1998 ~ "435",
                            Year == 1999 ~ "460",
                            Year == 2000 ~ "479",
                            Year == 2001 ~ "559",
                            Year == 2002 ~ "602",
                            Year == 2003 ~ "576",
                            Year == 2004 ~ "579",
                            Year == 2005 ~ "598",
                            Year == 2006 ~ "347",
                            Year == 2007 ~ "366",
                            Year == 2008 ~ "283",
                            Year == 2009 ~ "426"))
# turn avg into a numeric
tracs.date$avg <- as.numeric(tracs.date$avg)
# Make the year a date
tracs.date$Year <- as.Date(paste(tracs.date$Year, 1, 1, sep = "-"))




# plot a strip chart of year and yield
YIELD_PLOT <- ggplot(tracs.date, aes(x = Year, color = Entity)) +
  geom_jitter(aes(y = Yield), width = 75, shape = 1) +
  geom_line(aes(y = avg*18.75, color = "black")) +
  scale_y_continuous(name = "Yield - kg/ha",
                     sec.axis = sec_axis(~./18.75, name = "Mean tractors per 100 sq km per year")) +
  theme_classic() +
  ggtitle("Yields of countries and mean tractors per arable land") +
  theme(legend.position = "None", plot.title = element_text(hjust = 0.5)) 



YIELD_PLOT 


## 3.0 UAE Yield GGPLOT ####

# cut out the yield data for UAE
UAE_Yield <- na.omit(yield.shiny[yield.shiny$Entity == "United Arab Emirates",])

# select the years of interest
UAE_Yield <- UAE_Yield %>%
  filter(between(Year, 1994, 2004))

# factorise Commodity and Year
UAE_Yield$Year <- as.factor(UAE_Yield$Year)
UAE_Yield$Commodity <- as.factor(UAE_Yield$Commodity)




# ggplot
ggplot(UAE_Yield, aes(x = Year, y = tonnes_per_hectare, fill = Commodity)) +
  geom_bar(stat = "identity") +
  ggthemes::theme_economist() +
  coord_flip() +
  geom_text(UAE_Yield, mapping = aes(label = round(tonnes_per_hectare)), stat = "identity", position = "stack", hjust = 1.25) +
  ggtitle("Yield of commodities in the UAE") +
  ylab("Yield (t/ha)") +
  theme(plot.title = element_text(hjust = 0.5)) 

## 4.0 Mapping ####
use <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-01/land_use_vs_yield_change_in_cereal_production.csv')

names(use)[names(use) == 'Cereal yield index'] <- 'Yield_index'

# if require in the set up not always working....
#library(plotly)

yield_graph <- plot_geo(use,
                        locationmode = "world", 
                        frame = ~Year) %>%
  add_trace(locations = ~Code,
            z = ~Yield_index,
            zmin = 0,
            zmax = max(use$Yield_index),
            color = ~Yield_index,
            colorscale = 'Electric')

# yield_graph


# changing the annotation

use.map <- use %>%
  select(Year, Code, Yield_index, Entity)%>%
  mutate(hover = paste0(Entity, "\n", Yield_index))

fontstyle <- list(
  size = 15,
  color = "black"
)

label <- list(
  bgcolor = "#EEEEEE",
  bordercolor = "transparent",
  font = fontstyle
)


#mapping
yield_graph <- plot_geo(use.map,
                        locationmode = "world", 
                        frame = ~Year) %>%
  add_trace(locations = ~Code,
            z = ~Yield_index,
            zmin = 0,
            zmax = 1400,
            color = ~Yield_index,
            colorscale = 'Viridis', 
            text = ~hover,
            hoverinfo = 'text') %>%
  style(hoverlabel = label) %>%
  config(displayModeBar = F) %>%
  layout(title = "\nYield index of the world: 1961 - 2019") %>%
  colorbar(title = "Yield index")

yield_graph
# htmlwidgets::saveWidget(yield_graph, "Yield_Map.html")

## 5.0 Commodity BASE R ####

yield <-readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-01/key_crop_yields.csv')

#renaming
names(yield)[names(yield) == "Wheat (tonnes per hectare)" ] <- "Wheat"
names(yield)[names(yield) == "Rice (tonnes per hectare)" ] <- "Rice"
names(yield)[names(yield) == "Maize (tonnes per hectare)" ] <- "Maize"
names(yield)[names(yield) == "Soybeans (tonnes per hectare)" ] <- "Soybeans"
names(yield)[names(yield) == "Potatoes (tonnes per hectare)" ] <- "Potatoes"
names(yield)[names(yield) == "Beans (tonnes per hectare)" ] <- "Beans"
names(yield)[names(yield) == "Peas (tonnes per hectare)" ] <- "Peas"
names(yield)[names(yield) == "Cassava (tonnes per hectare)" ] <- "Cassava"
names(yield)[names(yield) == "Barley (tonnes per hectare)" ] <- "Barley"
names(yield)[names(yield) == "Cocoa beans (tonnes per hectare)" ] <- "Cocoa"
names(yield)[names(yield) == "Bananas (tonnes per hectare)" ] <- "Bananas"


# Data manipulation
# need one value for each year for each commodity
yield.graph <- yield %>%
  select(3:14) %>%
  group_by(Year) %>%
  summarise_each(funs(sum(., na.rm = T)))


attach(yield.graph) # data frame needs attaching in base r to prevent using the "df$" syntax
plot(Wheat, type = "l", lwd = 2,
     xaxt = "n", ylim = c(0,4000), col = "tan",
     xlab = "Year", ylab = "t/ha", 
     main = "Yield of commodities between 1961 to 2018")
axis(1, at = 1:length(Year), labels = Year)
lines(Rice, col = "red", type = "l", lwd = 2)
lines(Maize, col = "blue", type = "l", lwd = 2)
lines(Soybeans, col = "darkturquoise", type = "l", lwd = 2)
lines(Potatoes, col = "orange", type = "l", lwd = 2)
lines(Beans, col = "ivory4", type = "l", lwd = 2)
lines(Peas, col = "springgreen4", type = "l", lwd = 2)
lines(Cassava, col = "violet", type = "l", lwd = 2)
lines(Barley, col = "pink", type = "l", lwd = 2)
lines(Cocoa, col = "purple", type = "l", lwd = 2)
lines(Bananas, col = "yellow2", type = "l", lwd = 2)
# Creat the legend using the same colors
legend("topleft", legend = c("Wheat", "Rice", "Maize", "Soybeans", "Potatoes", "Beans",
                             "Peas", "Cassava", "Barley", "Cocoa", "Bananas"),
       lty = 1, lwd = 2, col = c("tan", "red", "blue", "darkturquoise", 
                                 "orange", "ivory4", "springgreen4",
                                 "violet", "pink", "purple", "yellow2"),
       ncol = 2, bty = "n", cex = 0.8,
       text.col = c("tan", "red", "blue", "darkturquoise", 
                    "orange", "ivory4", "springgreen4",
                    "violet", "pink", "purple", "yellow2"),
       inset = 0.01)

## 6.0 Land Use GGPLOT ####

land <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-01/arable_land_pin.csv')

# rename the long variable
names(land)[names(land) == "Arable land needed to produce a fixed quantity of crops ((1.0 = 1961))" ] <- "land_requirement"

# Make a value of continent names
continents <- c("Africa", "Europe", "Oceania", "Northern America", "South America", "Asia")


# cut out data for continents
land.cont <- land %>%
  dplyr::filter(Entity %in% continents) 

# Make the annotation a vector
(ggplot(land.cont, aes(x=Year, y=land_requirement, col=Entity)) +
    geom_line(lwd = 1) +
    theme_classic() +
    ggtitle("Change in the amount of arable land needed to produce a fixed quantity of crops") +
    theme(axis.title = element_text(size = 15, face = "bold"),
          axis.text = element_text(size = 13, color = "black"),
          legend.text = element_text(size = 13, colour = "black"),
          legend.title = element_text(size = 13, face = "bold"),
          title = element_text(face = "bold", size = 9)
    ) +
    ylab("Land required compared to 1961") +
    annotate("text", label = "Downward trend suggests", x = 1998, y = 0.9) +
    annotate("text", label = "that yield has increased.", x = 1998, y = 0.85))




