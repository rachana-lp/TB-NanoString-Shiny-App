
library(shiny)
library(tidyverse)
library(umap)
library(NMF)
library(mclust)

file_path <- file.choose()
TBnanostring <- readRDS(file_path)
TBnanostring$TB_Status <- as.factor(TBnanostring$TB_Status)

gene_data <- TBnanostring %>%
  select(-TB_Status) %>%
  as.data.frame()

gene_data <- as.data.frame(lapply(gene_data, as.numeric))

pca_app <- prcomp(gene_data, center = TRUE, scale. = FALSE)
pca_embedding <- pca_app$x[, 1:2]

set.seed(123)
umap_app <- umap(as.matrix(gene_data), n_neighbors = 15, random_state = 123)
umap_embedding <- umap_app$layout

nmf_matrix <- as.matrix(gene_data)
nmf_matrix <- sweep(nmf_matrix, 2, apply(nmf_matrix, 2, min), "-")

set.seed(123)
nmf_app <- NMF::nmf(nmf_matrix, rank = 2, nrun = 10)
nmf_embedding <- basis(nmf_app)

ui <- fluidPage(
  titlePanel("TB NanoString: Dimension Reduction and K-means"),
  sidebarLayout(
    sidebarPanel(
      selectInput("method", "Dimension reduction method",
                  choices = c("PCA", "UMAP", "NMF")),
      sliderInput("k", "Number of clusters (k)",
                  min = 2, max = 10, value = 2, step = 1)
    ),
    mainPanel(
      plotOutput("cluster_plot"),
      h4("Clusters vs. TB Status"),
      tableOutput("cluster_table"),
      textOutput("ari")
    )
  )
)

server <- function(input, output, session) {
  
  selected_embedding <- reactive({
    if (input$method == "PCA") {
      pca_embedding
    } else if (input$method == "UMAP") {
      umap_embedding
    } else {
      nmf_embedding
    }
  })
  
  clustering <- reactive({
    set.seed(123)
    kmeans(selected_embedding(), centers = input$k, nstart = 25)
  })
  
  plot_data <- reactive({
    coords <- as.data.frame(selected_embedding())
    colnames(coords) <- c("Dimension1", "Dimension2")
    coords$Cluster <- factor(clustering()$cluster)
    coords$TB_Status <- TBnanostring$TB_Status
    coords
  })
  
  output$cluster_plot <- renderPlot({
    centers <- as.data.frame(clustering()$centers)
    colnames(centers) <- c("Dimension1", "Dimension2")
    
    ggplot(plot_data(),
           aes(Dimension1, Dimension2,
               color = Cluster, shape = TB_Status)) +
      geom_point(size = 2.5) +
      geom_point(data = centers,
                 aes(Dimension1, Dimension2),
                 inherit.aes = FALSE,
                 shape = 4, size = 5, stroke = 1.5) +
      labs(title = paste(input$method, "with k-means clustering"),
           color = "Cluster", shape = "TB Status") +
      theme_minimal()
  })
  
  output$cluster_table <- renderTable({
    table(Cluster = clustering()$cluster,
          TB_Status = TBnanostring$TB_Status)
  }, rownames = TRUE)
  
  output$ari <- renderText({
    ari_value <- mclust::adjustedRandIndex(
      clustering()$cluster, TBnanostring$TB_Status
    )
    paste("Adjusted Rand Index:", round(ari_value, 3))
  })
}

shinyApp(ui = ui, server = server)
