
# TB NanoString Shiny App

This project uses the TB NanoString gene expression dataset to explore patterns in gene expression using dimension reduction and k-means clustering.

## Methods

The Shiny app allows users to select among three dimension reduction methods:

- Principal Component Analysis (PCA)
- Uniform Manifold Approximation and Projection (UMAP)
- Non-negative Matrix Factorization (NMF, rank 2)

Users can also select the number of clusters (k).

The app displays:
- A two-dimensional plot colored by k-means cluster.
- Point shapes representing TB status.
- K-means cluster centers.
- A table comparing clusters with TB status.
- The Adjusted Rand Index (ARI).

## Files

- `app.R`: Shiny application code.
- `TBnanostring.rds`: TB NanoString dataset.

## Requirements

R and the following packages:

- shiny
- tidyverse
- umap
- NMF
- mclust

## How to Run

1. Download `app.R` and `TBnanostring.rds`.
2. Open `app.R` in RStudio.
3. Run the app.
4. Select the dataset file when prompted.
5. Choose PCA, UMAP, or NMF and adjust the number of clusters.
