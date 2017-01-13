% local statistics
cooc = cooc_local(labelSubset,labelSubset);
cond1 = cooc ./ repmat(sum(cooc,2),1,length(labelSubset));
cond2 = cond1';
cooc = (cond1 + cond2) / 2;
cooc = cooc - diag(diag(cooc));
cooc = cooc + eye(size(cooc));
Sc = -alpha*log(cooc);

% spatialy varying part
im = double(im);
[Hc1 Vc1] = gradient(imfilter(squeeze(im(:,:,1)),fspecial('gauss',[3 3]),'symmetric'));
[Hc2 Vc2] = gradient(imfilter(squeeze(im(:,:,2)),fspecial('gauss',[3 3]),'symmetric'));
[Hc3 Vc3] = gradient(imfilter(squeeze(im(:,:,3)),fspecial('gauss',[3 3]),'symmetric'));
Hc = Hc1.^2+Hc2.^2+Hc3.^2;
Vc = Vc1.^2+Vc2.^2+Vc3.^2;
sigma = mean([Hc(:).^.5;Vc(:).^.5]);

gch = GraphCut('open', 5-Dc, Sc, single(exp(-.5*Vc/(sigma^2))), single(exp(-.5*Hc/(sigma^2))));
[gch, pixelLabels_hat] = GraphCut('swap',gch);
gch = GraphCut('close', gch);
pixelLabels_hat = pixelLabels_hat + 1;
predictLabel = labelSubset(pixelLabels_hat);
fprintf('Solving MRF in %f seconds\n', toc);



