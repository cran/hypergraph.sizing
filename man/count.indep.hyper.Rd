\name{count.indep.hyper}
\alias{count.indep.hyper}
\alias{count.vc.hyper}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Count the Number of Independent Sets for a Hypergraph
}
\description{
Counts the number of independent sets (or equivalently vertex covers) in
all initial subhypergraphs of the given hypergraph.
}
\usage{
count.indep.hyper(H,samp.size=1000)
count.vc.hyper(H,samp.size=1000)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{H}{
    The hypergraph, represented as a list with two components:
    \describe{
      \item{vertices}{The number of vertices in the hypergraph}
      \item{edges}{A list of edges. Each edge is a vector of vertex
	numbers. The order of the edges is important, as the function
	returns an approximate number of edges for each initial
	subhypergraph.}
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
  each time. The samp.size parameter is the number of such sequences generated. 
}
\value{
  A vector of length the number of edges. The ith entry in this vector
  is the approximate number of independent sets in the subhypergraph
  consisting of the first i edges of the hypergraph.
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

H<-list("vertices"=10,lapply(edge.orders,function(s){sample(seq_len(10),s)}))

ind.set<-count.indep.hyper(H)
}
