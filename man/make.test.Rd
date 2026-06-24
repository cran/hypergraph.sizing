\name{make.test}
\alias{make.test}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Standard hypothesis tests.
}
\description{
  Produces a standard hypothesis test for a given null hypothesis that a
  certain set of variables are null. These tests can be input to the
  get.p.values.hypergraph functions
}
\usage{
make.test(test.name)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{test.name}{
    The name of the test being used. Currently, options are "gaussian",
    "binomial" and "poisson".
  }
}
\details{
  Produces two-sided hypothesis tests for the null hypothesis that a
  set of predictors are all null, for the given GLM model. The models
  are fitted by the standard glm package, and p-values are calculated
  using ANOVA - a likelihood ratio test for "binomial" and "poisson",
  and an F-test for "gaussian".
}
\value{
  A test object, which is a list with two components:
  \describe{
    \item{model}{A function taking a formula as input and returning a
      fitted model.} 
    \item{p.val}{A function taking two nested fitted models as input and
      returning a p-value for the hypothesis that the outer model does
      not fit the data any better than the inner model.}
  }
  This test object can be used by the get.p.vals.hypergraph function to
  perform any collection of tests.
}
\author{
Toby Kenney
}
\examples{
set.seed(1)
X<-matrix(rnorm(200),20,10)\%*\%(diag(rep(1,10))-c(0.4,0.4,rep(0,8))\%*\%t(c(0.4,0.4,rep(0,8))))
Y<-rnorm(20)+X\%*\%c(0,2,0,2,2,0,0,0,0,0)

tst<-make.test("gaussian")

m1<-tst$model(Y~X)
X_sub<-X[,-c(1,2)]
m2<-tst$model(Y~X_sub)

tst$p.val(m1,m2)
}
