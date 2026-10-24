// ------------------------------------------------------
// Project EigenNet Functions
// Mahalanobis Distance Calculation
//  
// 
// Developer: Guenter Faes, eigennet@faes.de
// GitHub: https://github.com/SuprenumDE/EigenNet_Functions
// License: MIT
//
// Version 0.0.01, 07.10.2026
// ------------------------------------------------------

#pragma once

#include <Eigen/Dense>

namespace stats {

    inline double mahalanobis(
        const Eigen::VectorXd& x,
        const Eigen::VectorXd& mu,
        const Eigen::MatrixXd& Sigma)
    {
        // Numerisch stabile Lösung: Sigma^{-1} * (x - mu)
        Eigen::VectorXd diff = x - mu;

        // Sigma \ diff  → löst das lineare Gleichungssystem Sigma * y = diff
        double d2 = diff.transpose() * Sigma.ldlt().solve(diff);

        return std::sqrt(d2);
    }

} // namespace stats
