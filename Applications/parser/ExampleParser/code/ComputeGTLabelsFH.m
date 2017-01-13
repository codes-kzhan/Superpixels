% infer ground truth labels
tic
for f = 1 : length(trainList)
    
    name = trainList{f}
    outputfile = [gtDir name '.mat'];
    if exist(outputfile,'file')
        continue;
    end
    
    load([labelDir name '.mat']);
    labels = unique(S(:)); labels(find(labels==0)) = [];
    
    load([segDir name '.mat']);
    
    
    labelHist = cell(1,length(nBaseRegions));
    xLabels = cell(1,length(nBaseRegions));
    delta = cell(1,length(nBaseRegions));

    for kk = 1:length(nBaseRegions)
        
        labelHist{kk} = zeros(NC,nBaseRegions(kk));
        for cc = 1 : NC
            labelHist{kk}(cc,:) = accumarray(baseRegions{kk}(:), S(:)==cc);
        end

        [~,xLabels{kk}] = max(labelHist{kk},[],1);

        delta{kk} = zeros(NC,nBaseRegions(kk));
        for cc = 1 : NC
            delta{kk}(cc,:) = accumarray(baseRegions{kk}(:), S(:)~=cc, [nBaseRegions(kk) 1])';
        end
        
    end
    
    save(outputfile, 'labelHist', 'xLabels', 'delta');
    
    if mod(f,100)==0
        fprintf('Segment Labels: %d image in %f seconds.\n', f, toc);
    end
end