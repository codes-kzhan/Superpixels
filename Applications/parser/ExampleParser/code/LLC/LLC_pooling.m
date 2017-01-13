% ========================================================================
% Pooling the llc codes to form the image feature
% USAGE: [beta] = LLC_pooling(feaSet, B, pyramid, knn)
% Inputs
%       scode      -the coordinated local descriptors
%       frames           -the codebook for llc coding
%       pyramid     -the spatial pyramid structure
%       imsize         -the number of neighbors for llc coding
% Outputs
%       beta        -the output image feature
%
% Written by Jianchao Yang @ IFP UIUC
% May, 2010
% Modified by Jimei Yang @ UC Merced
% Dec.,2012
% ========================================================================

function [beta] = LLC_pooling(w, ix, frames, bbox, pyramid, sz)

img_width = bbox(3)-bbox(1)+1;
img_height = bbox(4)-bbox(2)+1;

% filter the frames out of bbox
outer = frames(1,:)<bbox(1) | frames(1,:)>bbox(3) | frames(2,:)<bbox(2) | frames(2,:)>bbox(4);
if sum(outer)>0
    w(:,outer) = [];
    ix(:,outer) = [];
    frames(:,outer) = [];
end
frames(1,:) = frames(1,:)-bbox(1)+1;
frames(2,:) = frames(2,:)-bbox(2)+1;

%w = abs(w);
idxBin = zeros(size(frames,2), 1);
% spatial levels
pLevels = length(pyramid);
% spatial bins on each level
pBins = pyramid.^2;
% total spatial bins
tBins = sum(pBins);

beta = [];
bId = 0;

for iter1 = 1:pLevels,
    
    nBins = pBins(iter1);
    
    wUnit = img_width / pyramid(iter1);
    hUnit = img_height / pyramid(iter1);
    
    % find to which spatial bin each local descriptor belongs
    xBin = ceil(frames(1,:) / wUnit);
    yBin = ceil(frames(2,:) / hUnit);
    idxBin = (yBin - 1)*pyramid(iter1) + xBin;
    
    regions = repmat(idxBin, [size(w,1) 1]);
    wordIndex = (regions-1)*sz+ix;
    tmp = accumarray(wordIndex(:),w(:),[nBins*sz 1],@max);
    beta = [beta, reshape(tmp,[sz,nBins])];

end

beta = beta.*(beta>0);
% beta = bsxfun(@times, beta, 1./sqrt(sum(beta.^2))+eps);
beta = beta(:);
% beta = beta./sqrt(sum(beta.^2));
