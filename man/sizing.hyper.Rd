\name{sizing.hyper}
\alias{sizing.hyper}
\title{
Create a Hypergraph-Based Sizing Function for GLSUP
}
\description{
Creates a hypergraph-based sizing function for the GLSUP package.
}
\usage{
sizing.hyper(H,samp.size=1000)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{H}{
    The hypergraph, represented as a list with two components:
    \describe{
      \item{vertices}{The number of vertices in the hypergraph}
      \item{edges}{A list of edges. Each edge is a vector of vertex
	numbers. The order of the edges is important, as the sizing
	function is calculated for each initial subhypergraph. }
    }
  }
  \item{samp.size}{
    The number of samples used to estimate the number of independent
    sets for each subhypergraph. Larger values take proportionately
    longer, but produce more accurate values. Because samples from
    subgraphs are reused for efficiency, this is not the exact number of
    samples used.
  }
}
\details{
  An independent set for a hypergraph is a set that contains no edges. A
  vertex cover is a set that has non-empty intersection with every
  edge. The complement of an independent set is a vertex cover, so there
  are the same number of independent sets as vertex covers. If the edges
  of a hypergraph are totally ordered, then we have a sequence of nested
  hypergraphs. These functions count the number of independent sets for
  each hypergraph in this nested sequence. Since counting the number of
  independent sets in a hypergraph is NP-hard, this function uses a
  random importance sampling scheme that sequentially samples
  independent sets starting from the empty set and adding one element
  each time. The samp.size parameter is the number of such sequences
  generated.

  For a hypergraph H of rejected hypotheses, the sizing function
  |V(H)|-log_2(|IS(H)|), where V(H) is the set of vertices of H and
  IS(H) is the set of independent sets, is suggested. This function
  returns a sizing function that calculates this for a nested sequence
  of hypergraphs from the full hypergraph.  
}
\value{
  A sizing function - that is a function that takes a permutation as
  input, then computes the function |V(H')|-log_2(|IS(H')|), where V(H')
  is the set of vertices of H' and IS(H') is the set of independent sets
  of H', for every H' obtained by taking the first i edges of H. This
  sizing function can be used with the GLSUP package to perform
  gFDR-controlled hypothesis testing for this sizing function. 
}
\references{
Hypergraph Variable Selection with False Discovery Rate Control

Sarah Organ, Toby Kenney, Hong Gu

<doi:10.48550/arXiv.2606.20514>
}
\author{
Toby Kenney
}
\examples{
set.seed(1)
edge.orders<-rpois(15,1.6)+1

H<-list("vertices"=10,"edges"=lapply(edge.orders,function(s){sample(seq_len(10),s)}))

sizing<-sizing.hyper(H)
sizing(seq_len(15))
}
