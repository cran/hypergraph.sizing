make.test<-function(test.name){
### Produces the standard hypothesis tests for testing sets of
### variables under common settings.
### Custom tests can be manually produced using the same format.
    if(test.name=="gaussian"){
        return(list("model"=stats::lm,
                    "p.val"=function(m1,m2){return(stats::anova(m1,m2)[2,"Pr(>F)"])}))
    }else if(test.name=="binomial"){
        return(list("model"=function(form){stats::glm(form, family = stats::binomial(link="logit"))},
                    "p.val"=function(m1,m2){return(stats::anova(m1,m2,test="Chisq")[2,"Pr(>Chi)"])}))
    }else if(test.name=="poisson"){
        return(list("model"=function(form){stats::glm(form, family = stats::poisson(link="log"))},
                    "p.val"=function(m1,m2){return(stats::anova(m1,m2,test="Chisq")[2,"Pr(>Chi)"])}))
    }else{
        stop(paste("Test \"",test.name,"\" not supported, please manually input test."))
    }
}


get.p.vals.hypergraph<-function(x,y,H,test){
### x     --- the matrix of predictors
### y     --- the vector of response variables
### H     --- a hypergraph whose edges are subsets to test
### test  --- a list with two components:
###       model --- a function for fitting the model based on a formula
###                 typically "lm" for gaussian regression, something
###                 based on "glm" for other glm models.
###       p.val --- a test function based on comparison of the two models
###                 typically based on the anova function

### Could write something much faster for gaussian regression, where
### only a single fitting is needed.

    if(is.character(test)){
        ## certain strings are possible for test
        test<-make.test(test)
    }

    if(H$vertices!=dim(x)[2]){
        stop("Vertices of hypergraph should correspond to predictors")
    }
    pv<-rep(1,length(H$edges))
    full<-test$model(y~x)
    for(i in seq_along(H$edges)){
        x_sub<-x[,-(H$edges[[i]])] # remove tested set of predictors
        if(dim(x_sub)[2]==0){
            ## empty submodel selected for comparison
            nested<-test$model(y~1)
        }else{
            nested<-test$model(y~x_sub)
        }
        pv[i]<-test$p.val(full,nested)
    }
    return(pv)
}
