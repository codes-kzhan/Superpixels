% Classify superpixels

%% superpixel segmentation
sigma = 0.8;
min_area = 25;
tempstr = 'segment/temp.ppm';
imwrite(im, tempstr,'ppm');
baseRegions = cell(length(kvalues),1);
nBaseRegions = zeros(length(kvalues),1);
for kk = 1:length(kvalues),
    k = round(kvalues(kk)*max(1,(length(im)/512)^2));
    ma = round(min_area*max(1,(length(im)/512)^2));
    segfile = ['segment/temp_k' num2str(k) '_fh.png'];
    % segment image                
    cmd = ['segment/segment ' num2str(sigma) ' ' num2str(k) ' ' num2str(ma) ' "' tempstr '" "' segfile '"' ];      
    system(cmd);
    segments = imread(segfile);
    labels = double(segments(:,:,1))*65536+double(segments(:,:,2))*256+double(segments(:,:,3));
    baseRegions{kk} = zeros(size(labels));
    values = unique(labels);
    nBaseRegions(kk) = length(values);
    for j = 1:length(values)
        baseRegions{kk}(labels==values(j)) = j;
    end
end

%% extract feature for query image
[descrs, descrsContext] = compute_superpixel_descriptors(im, baseRegions, nBaseRegions, siftVocab, colorVocab);
descrs = [cell2mat(descrs)];
descrsContext = [cell2mat(descrsContext)];
feaQR = single([descrs;descrsContext]);
if strcmp(kernel, 'Chi2')
    feaQR = vl_homkermap(feaQR, 1, 'KChi2', 'Gamma', 0.7);
end
if strcmp(kernel, 'Inters')
    feaQR = vl_homkermap(feaQR, 1, 'KINTERS', 'Gamma', 0.7);
end
if strcmp(kernel, 'Hellinger')
    feaQR = sqrt(abs(feaQR));
end

%% load example superpixel descriptors 
tic;
feaDB = cell(1,length(retrList));
gtDB = cell(1,length(retrList));
for f = 1 : length(retrList)
    load([descrDir retrList{f} '.mat']);
    load([gtDir retrList{f} '.mat']);
    descrs = cell2mat(descrs);
    descrsContext = cell2mat(descrsContext);
    ft = single([descrs;descrsContext]);
    labelHist = cell2mat(labelHist);
    [major, y] = max(labelHist,[],1);
    mask = major./sum(labelHist) > 0.95;
    gtDB{f} = y(mask);
    feaDB{f} = ft(:,mask);
end
feaDB = cell2mat(feaDB);
gtDB = cell2mat(gtDB);
labelSubset = unique(gtDB);
if strcmp(kernel, 'Chi2')
    feaDB = vl_homkermap(feaDB, 1, 'KChi2', 'Gamma', 0.7);
end
if strcmp(kernel, 'Inters')
    feaDB = vl_homkermap(feaDB, 1, 'KINTERS', 'Gamma', 0.7);
end
if strcmp(kernel, 'Hellinger')
    feaDB = sqrt(abs(feaDB));
end
fprintf('Loading example superpixel descriptors in %f seconds\n', toc);

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
fprintf('Computing KNN classification scores in %f seconds\n', toc);