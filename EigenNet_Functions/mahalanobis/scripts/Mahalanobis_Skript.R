################################################################################
##  An overview of the Mahalanobis distance as part of the EigenNET project
##  See also the MATLAB script Mahalanobis_Cluster.mlx at
##  https://github.com/SuprenumDE/EigenNET                               
## 
## Motivation:
## The R script is part of the EigenNET project's Dense_NN and OrthoFlow
## components and is included in the project's collection of methods. 
##
##
## GitHub: https://github.com/SuprenumDE/EigenNET/tree/main/EigenNet_Functions
##
## Guenter Faes, eigennet@faes.de
## Version 0.1.00, 23.10.2026
## R-Version: 4.6.1  
## OS Windows 11
##
################################################################################

library(ggplot2)
library(dplyr)
library(mclust)
library(gridExtra)
library(ggforce)
library(Rcpp)
library(RcppEigen)


# Load and compile the Mahalabonis function in a C++ script: 
Rcpp::sourceCpp("mahalanobis_rcpp.cpp")

#######################################################
# Comparison:
# Euclidean Distance vs. Mahalanobis Distance
# The Mahalanobis distance is calculated once using the R function “mahalanobis”
# and a second time using the C++ function “mahalanobis(.h)” from the 
# EigenNet project.
#######################################################

# Load sample data as a CSV file from the MATLAB script
# “Mahalanobis_Cluster.mlx”:
Datafile <- "C:/Temp/MahalanobisData.csv"
data <- read.csv(Datafile, header = FALSE, sep =",")

X <- data[,1:2]
label <- as.factor(data[,3])

# Calculate averages:
center <- colMeans(X)

# Euclidean distance to the center:
euclid <- sqrt(rowSums(sweep(X, 2, center)^2))


# Mahalanobis distance from the center:
maha <- mahalanobis(X, center = center, cov = cov(X))
maha <- sqrt(maha)

# Mahalanobis from EigenNET-Project:
X <- as.matrix(data[,1:2])
label <- as.factor(data[,3])
center <- colMeans(X)
Sigma  <- cov(X)

maha_cpp <- mahalanobis_rows(X, center, Sigma)

# Comparing the R Mahalabonis function with the C++ Mahalabonis functions
# from the EigenNET project:
max(abs(maha - maha_cpp))

# ---------------------------------------------------
# Generate a data frame for graphical output:Generate a 
# data frame for graphical output:

df_plot <- data.frame(
                      X1 = X[,1],
                      X2 = X[,2],
                      Label = as.integer(label),
                      Euclid = euclid,
                      Mahalanobis = maha,
                      Mahalanobis_CPP = maha_cpp
                      )

# ---------------------------------------------------
# Plot 1
# Euclidean distance
# ---------------------------------------------------

p1 <- ggplot(df_plot,
             aes(X1, X2,
                 color = Euclid)) +
  
  geom_point(size = 3) +
  
  scale_color_viridis_c() +
  
  ggtitle("Euclidean Distance") +
  
  theme_minimal()

# ---------------------------------------------------
# Plot 2
# Mahalanobis distance
# ---------------------------------------------------

p2 <- ggplot(df_plot,
             aes(X1, X2,
                 color = Mahalanobis)) +
  
  geom_point(size = 3) +
  
  scale_color_viridis_c() +
  
  ggtitle("Mahalanobis Distance") +
  
  theme_minimal()


# ---------------------------------------------------
# Plot 3
# C++ Mahalanobis distance
# ---------------------------------------------------

p3 <- ggplot(
  df_plot,
  aes(X1, X2,
      color = Mahalanobis_CPP)
) +
  
  geom_point(size = 3) +
  
  scale_color_viridis_c() +
  
  ggtitle("Mahalanobis Distance (EigenNET)") +
  
  theme_minimal()

# ---------------------------------------------------
# Presentation Plot 1 & 2
# ---------------------------------------------------

grid.arrange(p1, p2, p3, ncol = 3)


# --------------------------------------------------
#
# Application of Mahalanobis Distance Compared to
# Euclidean Distance in Cluster Analysis
#
# --------------------------------------------------
# ---------------------------------------------------
# 1. Example:
#
# K-Means Clustering
# ---------------------------------------------------

set.seed(123)

# Clustering
km <- kmeans(X, centers = 3)

# Create labels with cluster sizes
cluster_labels <- paste0("Cluster ", 1:length(km$size)," (n=", km$size, ")")

df_plot$Cluster <- factor(
  km$cluster,
  levels = 1:length(km$size),
  labels = cluster_labels
)

# Create Captions for Cluster Centers
SubTitleCenter <- paste(
  sapply(
    seq_len(nrow(km$centers)),\(i) sprintf("Cluster %d: %s",i,
      paste(round(km$centers[i, ], 2), collapse = " ")
    )
  ),
  collapse = "\n"
)

ggplot(df_plot, aes(X1, X2, color = Cluster)) +
  # Layer Graphic Labeling
  labs(
    title = "Distribution of Observations Across Clusters, k-means method",
    subtitle = SubTitleCenter,
    caption = paste0("GitHub: https://github.com/SuprenumDE/EigenNET,  Datafile: ",
                     Datafile)
  ) +

  geom_point(size = 3) +
  geom_point(
    data = data.frame(km$centers),
    aes(V1, V2),
    color = "black",
    shape = 8,
    size = 5
  ) +
  theme_minimal() 


# ---------------------------------------------------
# 2. Example:
#
# Model-based clustering based on parameterized finite
# Gaussian mixture models
#
# Implicit Use of the Mahalanobis Distance:
# K-Means assigns observations to cluster centers based
# on Euclidean distances.
#
# Gaussian Mixture Models (Mclust) additionally take the
# covariance structure of each cluster into account.
# Cluster membership is therefore based on probabilities
# and geometrically corresponds to a Mahalanobis distance
# to the center of the respective multivariate normal
# distribution.
# ---------------------------------------------------


# ---------------------------------------------------
# Mahalanobis ellipse function
# ---------------------------------------------------

ellipse_mahalanobis <- function(mu, Sigma, radius = 1, n = 200)
{
  theta <- seq(0, 2 * pi, length.out = n)
  
  circle <- rbind(
    cos(theta),
    sin(theta)
  )
  
  eig <- eigen(Sigma)
  
  ellipse <- eig$vectors %*%
    diag(sqrt(eig$values)) %*%
    circle * radius
  
  ellipse <- sweep(ellipse, 1, mu, "+")
  
  data.frame(
    X1 = ellipse[1, ],
    X2 = ellipse[2, ]
  )
}

# ---------------------------------------------------
# Clustering
# ---------------------------------------------------

gmm <- Mclust(X)

summary(gmm)

cat("\nSelected model:", gmm$modelName, "\n")

# ---------------------------------------------------
# Cluster sizes and labels
# ---------------------------------------------------

cluster_sizes <- tabulate(gmm$classification)

cluster_labels <- sprintf(
  "Cluster %d (n=%d)",
  seq_along(cluster_sizes),
  cluster_sizes
)

df_plot$Cluster <- factor(
  gmm$classification,
  levels = seq_along(cluster_sizes),
  labels = cluster_labels
)

# ---------------------------------------------------
# Subtitle with cluster centers
# ---------------------------------------------------

SubTitleCenter <- paste(
  sapply(
    seq_len(ncol(gmm$parameters$mean)),
    \(i)
    {
      sprintf(
        "Cluster %d: %s",
        i,
        paste(
          sprintf("%s=%.2f",rownames(gmm$parameters$mean), gmm$parameters$mean[, i]),
          collapse = ", "
        )
      )
    }
  ),
  collapse = "\n"
)

# ---------------------------------------------------
# Mahalanobis ellipses (1σ, 2σ, 3σ)
# The ellipses represent contours of constant Mahalanobis distance from the
# respective cluster center and are calculated directly from the covariance
# matrices estimated by the Gaussian mixture model.
# ---------------------------------------------------

ellipse_df <- do.call(
  rbind,
  lapply(
    seq_len(gmm$G),
    function(k)
    {
      do.call(
        rbind,
        lapply(
          1:3,
          function(radius)
          {
            tmp <- ellipse_mahalanobis(
              mu    = gmm$parameters$mean[, k],
              Sigma = gmm$parameters$variance$sigma[, , k],
              radius = radius
            )
            
            tmp$Cluster <- cluster_labels[k]
            tmp$Radius  <- factor(
              radius,
              levels = 1:3,
              labels = c("1σ", "2σ", "3σ")
            )
            
            tmp
          }
        )
      )
    }
  )
)

# ---------------------------------------------------
# Plot
# ---------------------------------------------------

ggplot(df_plot, aes(X1, X2, color = Cluster)) +
  
  labs(
    title = "Gaussian Mixture Model with Mahalanobis Ellipses",
    subtitle = SubTitleCenter,
    caption = paste0(
      "Mclust model: ",
      gmm$modelName,
      " | Datafile: ",
      Datafile
    )
  ) +
  
  geom_point(size = 3) +
  
  geom_point(
    data = data.frame(
      X1 = gmm$parameters$mean[1, ],
      X2 = gmm$parameters$mean[2, ]
    ),
    aes(X1, X2),
    shape = 8,        # Stern
    size = 5,
    colour = "black",
    linewidth = 1.2,
    inherit.aes = FALSE
  ) +
  
  geom_path(
    data = ellipse_df,
    aes(
      x = X1,
      y = X2,
      color = Cluster,
      group = interaction(Cluster, Radius),
      linetype = Radius
    ),
    linewidth = 1
  ) +
  
  scale_linetype_manual(
    values = c(
      "1σ" = "solid",
      "2σ" = "dashed",
      "3σ" = "dotted"
    )
  ) +
  
  theme_minimal() +
  
  theme(
    plot.subtitle = element_text(size = 10),
    legend.position = "right"
  )
# ---------------------------------------------------
# End of script



