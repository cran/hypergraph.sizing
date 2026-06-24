\name{complete.hypergraph}
\alias{complete.hypergraph}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Complete Hypergraph
}
\description{
Constructs a complete hypergraph containing all edges of order up to a
given value.
}
\usage{
complete.hypergraph(vertices,max.order)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{vertices}{
    The number of vertices
  }
  \item{max.order}{
    The largest number of vertices in an edge
  }
}
\details{
  Constructs a hypergraph containing all possible edges of order up to
  the parameter value max.order. Uses the combn function in the utils
  package, which lists edges in lexicographic order.
}
\value{
  The hypergraph, represented as a list with two components:
  \describe{
    \item{vertices}{The number of vertices in the hypergraph}
    \item{edges}{A list of edges. Each edge is a vector of vertex numbers.}
  }
  The hypergraph includes all edges with at most max.order vertices. The
  edges are in increasing order of size. Within each size, the edges are
  produced by the combn function in the utils package, which currently
  produces them in lexicographic order. 
}
\author{
Toby Kenney
}
\examples{
H<-complete.hypergraph(10,3)
H
}
