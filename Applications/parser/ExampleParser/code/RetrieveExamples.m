% load retrieval set
GistQR = im2gist(im);
gsims = GistQR'*GistDB;
[gsims,rank] = sort(gsims, 'descend');
retrList = trainList(rank(1:K));