<h1>Mahalanobis distance</h1>

![Mahalanobis Cluster](https://github.com/SuprenumDE/EigenNET/blob/main/images/Mahalanobis_Classification.png)

The **Mahalanobis distance** measures the distance between a point and a mean, taking into account the *covariance structure* of the data. It is therefore a scale- and correlation-adjusted distance, perfect for outlier detection, multivariate normal distributions, clustering, PCA, and **machine learning**.

The *PDF* file [Mahalanobis_Cluster.pdf](https://github.com/SuprenumDE/EigenNET/blob/main/EigenNet_Functions/mahalanobis/scripts/Mahalanobis_Cluster.pdf) or the [R script](https://github.com/SuprenumDE/EigenNET/blob/main/EigenNet_Functions/mahalanobis/scripts/Mahalanobis_Skript.R) in the [script directory](https://github.com/SuprenumDE/EigenNET/tree/main/EigenNet_Functions/mahalanobis/scripts) provide a good introduction to the Mahalanobis distance. Of course, you'll also find the necessary [**h**](https://github.com/SuprenumDE/EigenNET/blob/main/EigenNet_Functions/mahalanobis/scripts/mahalanobis.h) and [**cpp files**](https://github.com/SuprenumDE/EigenNET/blob/main/EigenNet_Functions/mahalanobis/scripts/mahalanobis_rcpp.cpp) in this directory.

The script directory also contains a sample dataset so you can quickly reproduce the R example.

R users should be familiar with the capabilities of **Rcpp**. German-speaking R users may find the YouTube [Rcpp Play List](https://www.youtube.com/watch?v=LVOgDn-iJVA&list=PLFmVgchSGbJjGz0tj2zxf8tzrfoZINX0v&pp=0gcJCVMDOCosWNinsAgC) playlist helpful.

**References:** Richard O. Duda, Peter E. Hart, David G. Stork, **Pattern Classification**, John Wiley & Sons. Inc, 2nd Edition
