library('e1071')

BOW.norm <- function(x, weights = NULL){
    x = 1 + log(x);
    x[x==-Inf] = 0;
    x.sum = as.matrix(x) %*% matrix(1,nrow=dim(x)[2],ncol=1);
    x.sum = matrix(100/x.sum,nrow=length(x.sum),ncol=dim(x)[2]);
    x.norm = x * x.sum;
    rm(x.sum);
    x.norm[is.na(x.norm)] = 0

    if (!is.null(weights)){
      x.norm =  x.norm  * matrix(abs(weights),ncol=length(weights),nrow=dim(x.norm)[1],byrow=T)
    }

    x.norm;
}


BOW.classification.model <- function(features, modelfile, dictfile = NULL){
    feats = read.table(features, sep="\t", header=T, row.names=1);

    if (!is.null(dictfile)){
        svm.weights = read.table(file=dictfile, sep="\t")[2];
    }else {
        svm.weights = NULL;
    }
    feats[-1] = BOW.norm(feats[-1], svm.weights);
    svm.model = svm(Class ~ ., data=feats, svm.weights);
    save(svm.model,svm.weights, file=modelfile);
}

BOW.classification.classify <- function(modelfile, x, weights = NULL){
    x = BOW.norm(x, weights);
    predict(modelfile, x);
}
