count.indep.hyper<-function(H,samp.size=1000){
### Counts the number of independent sets in the hypergraph H
### H has the following stucture:
### The first element gives the number of vertices.
### The second element is a list of edges.
### Each edge consist of a list of vertex numbers.
    nv<-as.integer(H$vertices)
    nsamp<-as.integer(samp.size)
    ne<-as.integer(length(H$edges))
    orders<-as.integer(lapply(H$edges,length))
    edges<-as.integer(unlist(H$edges)-1) # in c++ indices start at 0.
    answer<-vector("double",ne)
    returnval<-.C(count_indep_hyper_approx,answer,nv,ne,orders,edges,nsamp,PACKAGE="hypergraph.sizing")
    ans<-returnval[[1]]
    return(ans)
}

count.vc.hyper<-count.indep.hyper
### there are the same number of vertex covers and independent sets.

sizing.hyper<-function(H,samp.size=1000){
    sample.size<-samp.size
    Hyp<-H
    sizing<-function(ord){
        ## Reorder the edges of H in the given order
        H.temp<-list("vertices"=Hyp$vertices,"edges"=H$edges[ord])
        ind.set<-count.indep.hyper(H.temp,samp.size=sample.size)
        return(Hyp$vertices-log2(ind.set))
    }
}

complete.hypergraph<-function(vertices,max.order){
### constructs the complete hypergraph of all edges of order up to
### max.order on the given number of vertices.
    ln<-choose(vertices,seq_len(max.order))
    cum.ln<-cumsum(ln)
    ne<-cum.ln[max.order]
    edges<-vector(mode="list",length=ne)
    for(len in seq_len(max.order)){
        edges[(c(0,cum.ln)[len]+1):cum.ln[len]]<-utils::combn(vertices,len,simplify=FALSE)
    }
    return(list("vertices"=vertices,"edges"=edges))
}

get.threshold.hyper<-function(H,level,assumption="PRDS"){
    orders<-unlist(lapply(H$edges,length))
    sigma.i<- -log2(1-2^(-orders))
    if(is.null(assumption)){
        ##No dependency assumptions
        return((sum(sigma.i)*(1+log(H$vertices))-sum(sigma.i*log(sigma.i)))/level)
    }
    if(assumption=="PRDS" || assumption=="independent"){
        return(sum(sigma.i)/level)
    }
    stop(paste("Dependence assumption \"",assumption,"\" not known.",sep=""))
}
