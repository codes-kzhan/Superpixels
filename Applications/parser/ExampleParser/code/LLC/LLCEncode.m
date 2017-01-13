function [ix w] = LLCEncode(imwords, dictwords,K, beta, tree, maxComparisons)

if nargin < 3
    K = 5;
end
if nargin < 4
    beta = 1e-4;
end

if nargin < 5
    nframe=size(imwords,2);
    nbase=size(dictwords,2);
    XX = sum(imwords.*imwords);
    BB = sum(dictwords.*dictwords);
    distances  = repmat(XX, nbase, 1)-2*dictwords'*imwords+repmat(BB', 1, nframe);
    [dist ix] = sort(distances);
    ix(K+1:end,:) = [];
    dist(K+1:end,:) = [];
else    
    ix = vl_kdtreequery(tree, dictwords, imwords, 'NumNeighbors', K, 'MaxComparisons', maxComparisons);
end
ix_ = ix;
w = LLCEncodeHelper2(double(dictwords),double(imwords),double(ix_),beta);