% load segment features
tic
    
feaDB = cell(1,length(list));
gtDB = cell(1,length(list));

for f = 1 : length(list)

    load([descrDir list{f} '.mat']);
    load([gtDir list{f} '.mat']);

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

fprintf('Loading features in %f seconds\n', toc);