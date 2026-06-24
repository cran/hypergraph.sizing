\name{get.p.vals.hypergraph}
\alias{get.p.vals.hypergraph}
\title{Calculate p-values for set-wise variable selection from a hypergraph
}
\description{
  Performs Hypothesis Tests for the Null Hypothesis that a Set of
  Predictors Contains no True Predictor.
}
\usage{
get.p.vals.hypergraph(x,y,H,test)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
    The matrix of predictors.
  }
  \item{y}{
    A vector containing the response variable.
  }
  \item{H}{ A hypergraph represented as a list with two components:
    \describe{
      \item{vertices}{The number of vertices}
      \item{edges}{A list of subsets of vertices (represented as vectors
	of elements in the subset).}
    }
  }
  \item{test}{
    either one of the character strings "gaussian", "binomial" or
    "poisson", or else a list with two components:
    \describe{
      \item{model}{A function for fitting the model based on a formula
	typically "lm" for gaussian regression, something based on "glm"
	for other glm models.} 
      \item{p.val}{A test function based on comparison of the two models
	typically based on the anova function}
    }
    The make.test function creates a standard test of this form for
    "gaussian", "binomial" or "poisson" GLMs.
  }
}
\details{
  Each edge of the hypergraph corresponds to a collection of subsets of
  the predictor variables. This function, for each of these sets,
  computes the p-values for the hypotheses that the set contains no true 
  predictors.  
}
\value{
  A vector of p-values in the same order as the edges of the hypergraph.
}
\author{
  Toby Kenney
}
\examples{
set.seed(1)
X<-matrix(rnorm(200),20,10)\%*\%(diag(rep(1,10))-c(0.4,0.4,rep(0,8))\%*\%t(c(0.4,0.4,rep(0,8))))
Y<-rnorm(20)+X\%*\%c(0,2,0,2,2,0,0,0,0,0)
H<-complete.hypergraph(10,2)
get.p.vals.hypergraph(X,Y,H,"gaussian")
}
