load([labelDir query '.mat']);
       
alpha_ = alpha*sqrt((size(im,1)/256)*(size(im,2)/256));
% local statistics
if useContext
    cooc = cooc_local(labelSubset,labelSubset);
    cond1 = cooc ./ repmat(sum(cooc,2),1,length(labelSubset));
    cond2 = cond1';
    cooc = (cond1 + cond2) / 2;
    cooc = cooc - diag(diag(cooc));
    cooc = cooc + eye(size(cooc));
else
    cooc = exp(-ones(length(labelSubset))+eye(length(labelSubset)));
end
Sc = -alpha_*log(cooc);

% h = fspecial('gaussian', 5, 1);
% Dc_ = imfilter(Dc, h, 'same');

% [~,myLabel] = max(Dc,[],3);
% predictLabel = labelSubset(myLabel);
tic
im_ = imresize(im,0.5);
Dc_ = imresize(Dc,0.5);
% spatialy varying part
im_ = double(im_);
[Hc1 Vc1] = gradient(imfilter(squeeze(im_(:,:,1)),fspecial('gauss',[3 3]),'symmetric'));
[Hc2 Vc2] = gradient(imfilter(squeeze(im_(:,:,2)),fspecial('gauss',[3 3]),'symmetric'));
[Hc3 Vc3] = gradient(imfilter(squeeze(im_(:,:,3)),fspecial('gauss',[3 3]),'symmetric'));
Hc = Hc1.^2+Hc2.^2+Hc3.^2;
Vc = Vc1.^2+Vc2.^2+Vc3.^2;
sigma = mean([Hc(:).^.5;Vc(:).^.5]);

gch = GraphCut('open', 5-Dc_, Sc, single(exp(-.5*Vc/(sigma^2))), single(exp(-.5*Hc/(sigma^2))));
[gch, initialLabels0] = GraphCut('swap',gch);
gch = GraphCut('close', gch);
initialLabels0 = imresize(initialLabels0, [size(im,1),size(im,2)], 'nearest');
index0 = unique(initialLabels0+1);
Dc2 = Dc(:,:,index0);
labelSubset_ = labelSubset(index0);
labelmap = zeros(size(Dc_,3),1);
for ll = 1:length(index0)
    labelmap(index0(ll)) = ll-1;
end
initialLabels = int32(labelmap(initialLabels0+1));
% fprintf('Solving MRF initially in %f seconds\n', toc);
% 
% tic
% local statistics
if useContext
    cooc = cooc_local(labelSubset_,labelSubset_);
    cond1 = cooc ./ repmat(sum(cooc,2),1,length(labelSubset_));
    cond2 = cond1';
    cooc = (cond1 + cond2) / 2;
    cooc = cooc - diag(diag(cooc));
    cooc = cooc + eye(size(cooc));
else
    cooc = exp(-ones(length(labelSubset_))+eye(length(labelSubset_)));
end
Sc = -alpha_*log(cooc);
% spatialy varying part
im = double(im);
[Hc1 Vc1] = gradient(imfilter(squeeze(im(:,:,1)),fspecial('gauss',[3 3]),'symmetric'));
[Hc2 Vc2] = gradient(imfilter(squeeze(im(:,:,2)),fspecial('gauss',[3 3]),'symmetric'));
[Hc3 Vc3] = gradient(imfilter(squeeze(im(:,:,3)),fspecial('gauss',[3 3]),'symmetric'));
Hc = Hc1.^2+Hc2.^2+Hc3.^2;
Vc = Vc1.^2+Vc2.^2+Vc3.^2;
sigma = mean([Hc(:).^.5;Vc(:).^.5]);

gch = GraphCut('open', 5-Dc2, Sc, single(exp(-.5*Vc/(sigma^2))), single(exp(-.5*Hc/(sigma^2))));
gch = GraphCut('set', gch, initialLabels);
[gch, pixelLabels_hat] = GraphCut('swap',gch);
gch = GraphCut('close', gch);
pixelLabels_hat = pixelLabels_hat + 1;
predictLabel = labelSubset_(pixelLabels_hat);
toc_msmrf(i) = toc;
fprintf('Solving Multiscale MRF in %f seconds\n', toc_msmrf(i));

%{
tic;
Dc2 = shiftdim(-Dc,2);
im2 = shiftdim(im,2);
pixelLabels_hat2 = dense_inference_mex(single(Dc2), im2, 3, 3, alpha_, 20, 20);
pixelLabels_hat2 = pixelLabels_hat2 + 1;
predictLabel = labelSubset(pixelLabels_hat2);
fprintf('Solving dense MRF in %f seconds\n', toc);
%}

% convert labels
valid = find(S~=0);
pAcc = length(find(S(valid)==predictLabel(valid)))/length(valid);
averageAcc = [];
for cc = 1 : NC
    if sum(S(:)==cc)~=0
        averageAcc = [averageAcc; sum((S(:)==predictLabel(:))&(S(:)==cc))/sum(S(:)==cc)];
    end
end
cAcc = mean(averageAcc);
save(outputfile,'S','predictLabel','pAcc','cAcc');
fprintf('pAcc = %f\n',pAcc);

if visualize
    draw_label_image(predictLabel, palette, ['unlabeled';classes], i, pAcc);
    drawnow;
    labelstr = [outputDir query, '_' num2str(stage) '.png'];
    print(labelstr,'-dpng','-r96');
end

% draw_label_image(S, palette, ['unlabeled',classes]);
% labelstr = [num2str(i,'%04d'), '_gt.png'];
% print(labelstr,'-dpng','-r96');

% imwrite(uint8(im), [num2str(i,'%04d'), '_img.png']);



