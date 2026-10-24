// ------------------------------------------------------
// Project EigenNet Functions
// Mahalanobis Distance Calculation for Rcpp (R)
//  
// 
// Developer: Guenter Faes, eigennet@faes.de
// GitHub: https://github.com/SuprenumDE/EigenNet_Functions
// License: MIT
//
// Version 0.0.01, 19.10.2026
// ------------------------------------------------------

#include <RcppEigen.h>

// [[Rcpp::depends(RcppEigen)]]

#include "mahalanobis.h"

// [[Rcpp::export]]

Rcpp::NumericVector mahalanobis_rows(
    Eigen::MatrixXd X,
    Eigen::VectorXd mu,
    Eigen::MatrixXd Sigma)
{
    const int n = X.rows();

    Rcpp::NumericVector result(n);

    for (int i = 0; i < n; ++i)
    {
        Eigen::VectorXd x = X.row(i);

        result[i] =
            stats::mahalanobis(
                x,
                mu,
                Sigma
            );
    }

    return result;
}