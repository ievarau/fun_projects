###############
## Libraries ##
###############

library(shiny)
library(ggplot2)
library(ggseqlogo)

########
## UI ##
########

ui <- fluidPage(
  
  ## Application title:
  titlePanel("Plot a word as a sequence logo"),
  
  ## Sidebar:
  sidebarLayout(
    sidebarPanel(
      
      ## Text input:
      textInput("txt", "Write a word bellow: ", placeholder = "Hello", value = "Hello"),
      
      ## Downloading the plot: 
      downloadButton("downloadPlot", "Download LOGO")
      
    ),
  
  mainPanel(
    plotOutput("plot")
  ))
  
)

############
## SERVER ##
############

server <- function(input, output) {
  
  wordLogo <- reactive({
    
    input_word <- input$txt
    output_word <- toupper(input_word)
    
    
    ## Converting a word into a vector and counting letters:
    word_vector <- unlist(strsplit(output_word, ""))
    word_len <- length(word_vector)
    
    unique_letters <- unique(word_vector)
    unique_letters <- unique_letters[unique_letters != " "]
    nb_of_unique_letters <- length(unique_letters)
    
    ## Making a PFM:
    ## Matrix of random small numbers:
    small_nb_vector <- 0:10
    word_matrix <- matrix(sample(small_nb_vector, 
                                 size = (word_len + 4) * nb_of_unique_letters,
                                 replace = TRUE),
                          nrow = nb_of_unique_letters,
                          dimnames = list(unique_letters))
    
    ## Altering the counts to emphasize the word letters:
    large_nb_vector <- 170:200
    
    for (i in 1:word_len) {
      
      letter_id <- word_vector[i]
      
      if (letter_id != " ") {
        word_matrix[letter_id, i + 2] <- sample(large_nb_vector, size = 1)
        
      }
      
      ## Plotting the logo:
      vector_of_colours <- c("#255C99", "#D62839", "#F7B32B", "#109648", "#984ea3",
                             "#ff7f00", "#b15928", "#fccde5", "#8dd3c7", "#b3de69",
                             "#80b1d3", "#fb8072", "#bc80bd")
      
      colour_scheme <- make_col_scheme(chars  = unique_letters,
                                       cols   = vector_of_colours[1:nb_of_unique_letters])
      
      word_logo <- ggseqlogo(word_matrix,
                             col_scheme = colour_scheme,
                             method = 'custom') +
        theme_void()
    }
    
    return(word_logo)
    
    })
  
  output$plot <- renderPlot({
    wordLogo()
    })
  
  output$downloadPlot <- downloadHandler(
    filename = function(){paste(input$txt, ".png", sep = "")},
    content = function(file){
      png(file = file)
      plot(wordLogo())
      dev.off()
      # ggsave(file,
      #        plot = output$plot)
    }
  )
  # output$download <- downloadHandler(
  #   filenanme = "word_logo.pdf",
  #   content   = function(file) {
  #     device <- function(..., width, height) {
  #       grDevices::pdf(..., width = width, height = height)
  #     }
  #     ggsave(filename = file,
  #            plot = output$plot,
  #            device = device)
  #   })

}

#########################
## Run the application ##
#########################

shinyApp(ui = ui, server = server)

###################
## End of script ##
###################