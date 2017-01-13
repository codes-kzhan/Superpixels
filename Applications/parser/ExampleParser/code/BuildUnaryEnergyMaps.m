% build unary energy maps
%% Superpixel scoring
tic
segSim = feaQR'*feaDB;
segSim = segSim./repmat(sum(feaQR.*feaQR)',1,size(feaDB,2));
[osim, orders] = sort(segSim, 2, 'descend');
osim = osim(:,1:knn); osim = bsxfun(@times, osim, 1./(sum(osim,2)+eps));
orders = orders(:,1:knn);
yy = gtDB(orders);
scores = zeros(NC,size(segSim,1));
for ss = 1:size(segSim,1);
    scores(:,ss) = accumarray(yy(ss,:)', osim(ss,:), [NC,1]);
end
scores = scores(labelSubset,:);
fprintf('Computing KNN scores in %f seconds\n', toc);

tic
%% Pixel scoring
unary = scores;
nums = [0;cumsum(nBaseRegions)];
Dc = -Inf(size(baseRegions{1},1),size(baseRegions{1},2), length(labelSubset));
for kk = 1:length(nBaseRegions)
    for cc = 1:length(labelSubset)
        temp = unary(cc,nums(kk)+1:nums(kk+1));
        temp = temp(baseRegions{kk});
        Dc(:,:,cc) = max(Dc(:,:,cc),temp);
    end
end