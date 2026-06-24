\name{get.threshold.hyper}
\alias{get.threshold.hyper}
\title{
Calculate a Threshold to Control FDR for Hypergraph-Based GLSUP
}
\description{
Calculates a threshold to control gFDR at the specified level when using
GLSUP for hypotheses corresponding to the edges of a hypergraph, using a
conservative bound on the independent set sizing function.
}
\usage{
get.threshold.hyper(H,level,assumption="PRDS")
}
\arguments{
  \item{H}{
    The hypergraph, represented as a list with two components:
    \describe{
      \item{vertices}{The number of vertices in the hypergraph.}
      \item{edges}{A list of edges. Each edge is a vector of vertex
	numbers. The order of the edges is important, as the sizing
	function is calculated for each initial subhypergraph. }
    }
  }
  \item{level}{
    The desired gFDR control level for GLSUP.
  }
  \item{assumption}{
    The assumptions for the dependency between null p-values. Options
    are "PRDS", "independent" or null. "PRDS" and "independent" give the
    same threshold, while null gives a more conservative threshold.
  }
}
\details{
  The GLSUP rejects as many hypotheses as possible such that the sizing
  function applied to the rejected hypotheses exceeds a threshold
  multiplied by the p-value cut-off. This threshold is calculated based
  on the assumptions about dependency between null p-values, and the
  desired gFDR control level. This function performs these calculations
  under common cases.
}
\value{
  The threshold for FDR control.
}
\references{
Hypergraph Variable Selection with False Discovery Rate Control

Sarah Organ, Toby Kenney, Hong Gu

<doi:10.48550/arXiv.2606.20514>



Setwise Hierarchical Variable Selection and the Generalized Linear
Step-Up Procedure for False Discovery Rate Control 

Sarah Organ, Toby Kenney, Hong Gu
<doi:10.48550/arXiv.2603.02160>
  
}
\author{
Toby Kenney
}
\examples{
set.seed(1)
edge.orders<-rpois(15,1.6)+1

H<-list("vertices"=10,"edges"=lapply(edge.orders,function(s){sample(seq_len(10),s)}))
get.threshold.hyper(H,0.05,assumption="PRDS")

}
