/* Method for counting independent sets of a hypergraph.

This assumes the edges of a hypergraph are in a specific order, and counts the number of independent sets of each initial segment of the hypergraph. 
   
 */

#include <cstdlib>
#include <cmath>
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

using namespace std;

inline unsigned int random(unsigned int n){
  //generates a random number in the range 0 to n-1.

  double ru=unif_rand();
  return(floor(ru*n));
  
//  unsigned int r=rand();
//  for(;r>(RAND_MAX/n)*n;r=rand());
//  return r%n;
};


class Permutation{
  unsigned int n;
  unsigned int *pi;
  unsigned int *inverse;
  unsigned int pos;
  char* skip; 
  
public:
  Permutation(unsigned int sz);
  ~Permutation();
  void random();
  unsigned int next();
  void set_skip(unsigned int i);
};

Permutation::~Permutation(){
  delete[] pi;
  delete[] inverse;
  delete[] skip;
};

Permutation::Permutation(unsigned int sz):n(sz),pos(0){
  pi=new unsigned int[n];
  inverse=new unsigned int[n];
  skip=new char[n];
  for(unsigned int i=0;i<n;i++){
    pi[i]=i;
    inverse[i]=i;
    skip[i]=0;
  };   
};


inline void Permutation::set_skip(unsigned int i){
  *(skip+inverse[i])=1;
  for(;pos<n&&skip[pos];pos++);
};

void Permutation::random(){
  // randomly switch value in each position i with a later value, or
  // the same value.
  for(unsigned int i=0;i<n-1;i++){
    unsigned int s=::random(n-i);
    unsigned int temp=*(pi+i);
    *(pi+i)=*(pi+i+s);
    *(pi+i+s)=temp;
  };
  for(unsigned int i=0;i<n;i++){
    *(inverse+*(pi+i))=i;
    *(skip+i)=0;
  };
  pos=0;
};

unsigned int Permutation::next(){
  if(pos<n){
    unsigned int ans=pi[pos];
    for(pos++;pos<n&&*(skip+pos);pos++);
    return ans;
  }else{
    pos=0;
    return n; // If finished, return n.
  };
};

class list{
public:
  unsigned int size;
  unsigned int* elements;

  void setsize(unsigned int n);
  void setelement(unsigned int pos,unsigned int val);
  void set(unsigned int n,const bool *selected);
  void set_list(unsigned int n,const unsigned int *entries);
  void set_list(unsigned int n,const int *entries);
  list();
  ~list();
};

void list::setsize(unsigned int n){
  if(elements){
    delete[] elements;
  };
  size=n;
  elements=new unsigned int[size];
};

void list::setelement(unsigned int pos,unsigned int val){
  if(pos<size){
    elements[pos]=val;
  };
};


void list::set(unsigned int n,const bool *selected){
  if(elements){
    delete[] elements;
  };
  size=0;
  for(unsigned int i=0;i<n;i++){
    if(selected[i]){
      size++;
    };
  };
  elements=new unsigned int[size];
  unsigned int j=0;
  for(unsigned int i=0;i<n;i++){
    if(selected[i]){
      elements[j++]=i;
    };
  };
};


void list::set_list(unsigned int n,const unsigned int *entries){
  if(elements){
    delete[] elements;
  };
  size=n;
  elements=new unsigned int[size];  
  for(unsigned int i=0;i<size;i++){
    elements[i]=entries[i];
  };
};

void list::set_list(unsigned int n,const int *entries){
  if(elements){
    delete[] elements;
  };
  size=n;
  elements=new unsigned int[size];  
  for(unsigned int i=0;i<size;i++){
    elements[i]=entries[i];
  };
};


list::list(){
  size=0;
  elements=NULL;
};

list::~list(){
  if(elements){
    delete[] elements;
  };
};


class hypergraph{
  unsigned int nv; //number of vertices
  unsigned int ne; //number of edges
  list *vertices; //each vertex is a list of the edges that contain it.
  list *edges; //each edge is a list of the vertices it contains.
  //edges are in order.
  
  //Temporary calculation variables
  unsigned char* used; //Indicates whether a vertex is already included or excluded.
  unsigned int* order; //The order of each edge in the reduced hypergraph.
  //Set to zero if the edge is removed.

public:
  
  hypergraph(unsigned int edgenum,unsigned int vertnum);
  ~hypergraph();
  void random(double p); //generates a random hypergraph with the
			 //specified number of edges, where each edge
			 //contains each vertex with probability p.
  void read(const unsigned int *ord,const unsigned int *eds);
  void read(const int *ord,const int *eds);
  double* countindep(unsigned int N); //performs the subsampling   
};

hypergraph::hypergraph(unsigned int edgenum,unsigned int vertnum):nv(vertnum),ne(edgenum){
  vertices=new list[nv]; 
  edges=new list[ne]; 
  used=new  unsigned char[nv];
  order=new unsigned int[ne];
};

hypergraph::~hypergraph(){
  delete[] vertices;
  delete[] edges;
  delete[] used;
  delete[] order;
};


void hypergraph::random(double p){
  //generates a random hypergraph with the specified numb
  bool *sel=new bool[nv];
  unsigned int* degree=new unsigned int[nv];
  for(unsigned int i=0;i<nv;i++){
    degree[i]=0;
  };
  for(unsigned int i=0;i<ne;i++){
    for(unsigned int j=0;j<nv;j++){
      sel[j]=unif_rand()<p;
      if(sel[j]){
	degree[j]++;
      };
    };
    (edges+i)->set(nv,sel);
  };
  for(unsigned int i=0;i<nv;i++){
    (vertices+i)->setsize(degree[i]);
    degree[i]=0; //use degree to count position.
  };
  for(unsigned int i=0;i<ne;i++){
    for(unsigned int j=0;j<(edges+i)->size;j++){
      unsigned int k=(edges+i)->elements[j];
      (vertices+k)->setelement(degree[k]++,i);
    };
  };
  delete[] sel;
  delete[] degree;
};

void hypergraph::read(const unsigned int *ord,const unsigned int *eds){
  //Reads in a hypergraph from a list of orders and the concatenated
  //list of vertices.
  const unsigned int* current=eds;
  for(unsigned int i=0;i<ne;i++){
    (edges+i)->set_list(ord[i],current);
    current+=ord[i];
  };
    

  unsigned int* degree=new unsigned int[nv];
  for(unsigned int i=0;i<nv;i++){
    degree[i]=0;
  };
  for(unsigned int i=0;i<ne;i++){
    for(unsigned int j=0;j<(edges+i)->size;j++){
      unsigned int k=(edges+i)->elements[j];
      degree[k]++;
    };
  };

  for(unsigned int i=0;i<nv;i++){
    (vertices+i)->setsize(degree[i]);
    degree[i]=0; //use degree to count position.
  };
  for(unsigned int i=0;i<ne;i++){
    for(unsigned int j=0;j<(edges+i)->size;j++){
      unsigned int k=(edges+i)->elements[j];
      (vertices+k)->setelement(degree[k]++,i);
    };
  };

  delete[] degree;  
};


void hypergraph::read(const int *ord,const int *eds){
  //Reads in a hypergraph from a list of orders and the concatenated
  //list of vertices.

  const int* current=eds;
  for(unsigned int i=0;i<ne;i++){
    (edges+i)->set_list(ord[i],current);
    current+=ord[i];
  };


  unsigned int* degree=new unsigned int[nv];
  for(unsigned int i=0;i<nv;i++){
    degree[i]=0;
  };
  for(unsigned int i=0;i<ne;i++){
    for(unsigned int j=0;j<(edges+i)->size;j++){
      unsigned int k=(edges+i)->elements[j];
      degree[k]++;
    };
  };

  for(unsigned int i=0;i<nv;i++){
    (vertices+i)->setsize(degree[i]);
    degree[i]=0; //use degree to count position.
  };
  for(unsigned int i=0;i<ne;i++){
    for(unsigned int j=0;j<(edges+i)->size;j++){
      unsigned int k=(edges+i)->elements[j];
      (vertices+k)->setelement(degree[k]++,i);
    };
  };

  delete[] degree;  
};




double* hypergraph::countindep(unsigned int N){
  //Counts the number of independent sets, using an importance
  //sampling approach based on randomly constructing an independent
  //set.
  double* ans=new double[ne];
  double* count=new double[ne];
  double* factor=new double[ne]; // factor is the weight that is
				 // assigned to samples based on one
				 // subgraph for analysing another
				 // subgraph.
  for(unsigned int i=0;i<ne;i++){
    ans[i]=0;
    if(i){
      factor[i]=1-ldexp((double)1,-(edges+i)->size);
    }else{
      factor[0]=1;
    };
  };
  Permutation perm(nv);
  count[0]=0;
  for(unsigned int sge=0;sge<ne;sge++){
    if(sge){
      count[sge]=count[sge-1]*(1-ldexp((double)1,-(edges+sge)->size));
    };
    // loop over the subhypergraph consisting of the first sge edges. 
    for(;count[sge]<N;count[sge]++){
      //initialise used and order variables
      double fact=1;
      for(unsigned int j=sge;j<ne;j++){
	*(ans+j)+=fact;
	fact*=factor[j+1]; //empty set is independent.
      };
      for(unsigned int i=0;i<nv;i++){
	used[i]=0;
      };
      for(unsigned int i=0;i<ne;i++){
	order[i]=(edges+i)->size;
      };
      perm.random();
      unsigned int avail=nv;
      // remove all loops
      // could do this once for all permutations.
      for(unsigned int e=0;e<sge;e++){
	if(order[e]==1){
	  unsigned int l=(edges+e)->elements[0];
	  used[l]=1;
	  avail--;
	  perm.set_skip(l); // vertex l cannot be added to the independent set	
	  // Remove all edges that contain vertex l, as they can
	  // never be completed.
	  for(unsigned int m=0;m<(vertices+l)->size;m++){
	    order[(vertices+l)->elements[m]]=0;
	  };
	};
      };
      
      double w=1;
      //      double tot=1;
      unsigned int iter=1;
      unsigned int ind_limit=ne; // The largest graph at which it becomes dependent.
      for(unsigned int i=perm.next();i<nv;i=perm.next()){
	//i is added to the independent set.
	w*=((double)avail)/(iter++);
	//	tot+=w;
	// Need to modify this to keep track of contribution to all totals. 
	used[i]=1;
	avail--;
	//remove i from all edges that contain it.
	for(unsigned int j=0;j<(vertices+i)->size;j++){
	  unsigned int e=(vertices+i)->elements[j];
	  if(order[e]){
	    order[e]--;
	    if(order[e]==1&&e<=sge){
	      //This edge has become a loop.
	      //Remove the remaining vertex.
	      unsigned int k=0;
	      for(;k<(edges+e)->size&&used[(edges+e)->elements[k]];k++);
	      unsigned int l=(edges+e)->elements[k];
	      used[l]=1;
	      avail--;
	      perm.set_skip(l); // vertex l cannot be added to the independent set. 
	      // Remove all edges that contain vertex l, as they can
	      // never be completed.
	      for(unsigned int m=0;m<(vertices+l)->size;m++){
		order[(vertices+l)->elements[m]]=0;
	      };
	    }else if(order[e]==0&&e<ind_limit){
	      // The current set is no longer independent at stage e.
	      ind_limit=e;
	    };
	  };
	};
	fact=1;
	for(unsigned int j=sge;j<ind_limit;j++){
	  *(ans+j)+=w*fact;
	  fact*=factor[j+1];
	};
      };
    };
    *(ans+sge)/=count[sge];
  };
  delete[] count;
  delete[] factor;
  return ans;    
};

extern "C"{

  void count_indep_hyper_approx(double *answer,const int* nv,const int* ne,const int* orders,const int *edges,const int *nsamp){
    GetRNGstate();
    hypergraph h(*ne,*nv);
    h.read(orders,edges);
    double *ans=h.countindep(*nsamp);
    for(unsigned int i=0;i<*ne;i++){
      *(answer+i)=*(ans+i);
    };
    delete[] ans;
    PutRNGstate();
};


static const R_CMethodDef CEntries[] = {
    {"count_indep_hyper_approx", (DL_FUNC) &count_indep_hyper_approx, 6},
    {NULL, NULL, 0}
};

void R_init_hypergraph_sizing(DllInfo *dll)
{
    R_registerRoutines(dll, CEntries, NULL, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}

  
};
  
