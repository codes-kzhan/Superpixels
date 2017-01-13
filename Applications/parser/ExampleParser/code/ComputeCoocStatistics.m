% compute co-occurrence statistics
cooc_local = zeros(NC);
for ii = 1:numel(trainList)
    ii

    load([gtsegDir trainList{ii} '.mat']);
    
    pairwise = pairwiseboundarylen(baseRegions);
    
    for jj = 1:size(pairwise,1)
        l1 = xLabels(jj);
        if l1 ~= 0
            neighbors = find(pairwise(jj,:));
            for kk = 1:length(neighbors)
                l2 = xLabels(neighbors(kk));
                if l1~=l2 && l2~=0
                    cooc_local(l1,l2) = cooc_local(l1,l2) + 1;
                end
            end
        end
    end
    
end
cooc_local = cooc_local + 1;
cond1 = cooc_local ./ repmat(sum(cooc_local,2),1,NC);
cond2 = cond1';
cooc_local_normalized = (cond1 + cond2) / 2;
cooc_local_normalized = cooc_local_normalized - diag(diag(cooc_local_normalized));
cooc_local_normalized = cooc_local_normalized + eye(size(cooc_local_normalized));

figure; imagesc(log(cooc_local));
set(gca,'XTick',1:NC)
set(gca,'XTickLabel',classes)
set(gca,'YTick',1:NC)
set(gca,'YTickLabel',classes)
save(coocDir,'cooc_local','cooc_local_normalized');
% % global statistics
% cooc_global = zeros(NC);
% for ii = 1:numel(list)
%     load([gtDir list{ii} '.mat']);
%     oc = zeros(NC,1);
%     labels = unique(xLabels);
%     for jj = 1:length(labels)
%         oc(labels(jj)) = 1;
%     end
%     cooc_global = cooc_global + oc*oc';
% end
% cooc_global = cooc_global + 1;
% cond1 = cooc_global ./ repmat(sum(cooc_global,2),1,NC);
% cond2 = cond1';
% cooc_global_normalized = (cond1 + cond2) / 2;
% cooc_global_normalized = cooc_global_normalized - diag(diag(cooc_global_normalized));
% cooc_global_normalized = cooc_global_normalized + eye(size(cooc_global_normalized));
% figure; imagesc(log(cooc_global));
% set(gca,'XTick',1:NC)
% set(gca,'XTickLabel',classes)
% set(gca,'YTick',1:NC)
% set(gca,'YTickLabel',classes)
% save('output/SIFTflow/cooc.mat','cooc_local','cooc_global','cooc_local_normalized','cooc_global_normalized');