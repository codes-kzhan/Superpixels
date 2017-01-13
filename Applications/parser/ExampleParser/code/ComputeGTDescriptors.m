% compute extended features (color histogram, location, shape)

clear all;
RunSystemSIFTflow;

ids = [trainIds];
N = length(ids);
xLocZones = 6;
yLocZones = 6;
llcK = 5;
load(['output/SIFTflow/siftVocab' num2str(1024) '.mat']);
load(['output/SIFTflow/colorVocab' num2str(128) '.mat']);

tic;
for f = 1:numel(ids)
    
    id = ids(f);
    imfile = imPaths{id};
    found = strfind(imPaths{id}, keyword);
    name = imPaths{id}(found+length(keyword)+1:end-4);
    found = strfind(name, '/');
    subdir = name(1:found(end));
    if ~isdir([gtdescrDir,subdir]) 
        mkdir([gtdescrDir,subdir]);
    end
    outputfile = [gtdescrDir name '.mat'];
    if exist(outputfile,'file')
%         continue;
    end
    
    im = imread(imfile);
    load([gtsegDir name '.mat']);
    load([siftDir name '.mat']);
    load([scodeDir name '.mat']);
    
    nBaseRegions = length(xLabels);
    
    %computing sift histograms for base regions
    loc = sub2ind(imsize, round(frames(2,:)'), round(frames(1,:)'));
    regions = baseRegions(loc);
    regions = repmat(regions', [llcK 1]);
    wordIndex = (regions-1)*size(siftVocab,2)+ix;
    wordHist = accumarray(wordIndex(:),w(:),[nBaseRegions*size(siftVocab,2) 1],@max);
    wordHist = reshape(wordHist,[size(siftVocab,2) nBaseRegions]);

    %computing color histograms for base regions
    colors = reshape(shiftdim(im,2),[3 size(im,1)*size(im,2)]);
    colors = vl_ikmeanspush(colors,colorVocab);
    colorHist = accumarray([colors(:) baseRegions(:)],...
       ones(numel(colors),1), [size(colorVocab,2) nBaseRegions]);

    %computing location histograms for base regions
    [y x] = ndgrid(1:size(im,1),1:size(im,2));
    y = ceil(y/size(im,1)*yLocZones);
    x = ceil(x/size(im,2)*xLocZones);
    locations = (y-1)*xLocZones+x;
    locHist = accumarray([locations(:) baseRegions(:)],...
       ones(numel(locations),1), [xLocZones*yLocZones nBaseRegions]);       

    %computing shape histograms for base regions
    bboxes = zeros(4,nBaseRegions);
    for i = 1:nBaseRegions
        mask = (baseRegions == i);
        if sum(mask(:))>0
            rangx = find(sum(mask,1));  
            rangy = find(sum(mask,2));
            minx = rangx(1); maxx = rangx(end);
            miny = rangy(1); maxy = rangy(end);
            bboxes(:,i) = [minx;miny;maxx;maxy];
        else
            bboxes(:,i) = [1;1;1;1];
        end
    end
    shapeHist = phog(im, bboxes);

    %L1-normalization
    wordHist = bsxfun(@times, wordHist, 1./(sum(wordHist)+eps));
    colorHist = bsxfun(@times,colorHist,1.0./(sum(colorHist)+1e-10));
    locHist = bsxfun(@times,locHist,1.0./(sum(locHist)+1e-10));
    shapeHist = bsxfun(@times,shapeHist,1.0./(sum(shapeHist)+1e-10));

    descrs = [wordHist;colorHist;locHist;shapeHist];

    %compute context features
    wordHistContext = zeros(size(siftVocab,2), nBaseRegions,'single');
    colorHistContext = zeros(size(colorVocab,2), nBaseRegions,'single');
    locHistContext = zeros(xLocZones*yLocZones, nBaseRegions,'single');
    bboxContext = zeros(4,nBaseRegions);
    for i = 1:nBaseRegions
        mask = (baseRegions == i);
        if sum(mask(:))>0
            se = strel('diamond', 10);
            mask = imdilate(mask, se);
            rangx = find(sum(mask,1));  
            rangy = find(sum(mask,2));
            minx = rangx(1); maxx = rangx(end);
            miny = rangy(1); maxy = rangy(end);
            bboxContext(:,i) = [minx;miny;maxx;maxy];
            validLoc = mask(loc);
            subIndex = ix(:,validLoc>0);
            subCoeff = w(:,validLoc>0);
            wordHistContext(:,i) = accumarray(subIndex(:),subCoeff(:),[size(siftVocab,2) 1],@max);
            subColors = colors(:,mask>0);
            colorHistContext(:,i) = accumarray(subColors(:),ones(numel(subColors),1), [size(colorVocab,2) 1]);
            subLocations = locations(mask>0);
            locHistContext(:,i) = accumarray(subLocations(:),ones(numel(subLocations),1), [xLocZones*yLocZones 1]); 
        else
            bboxContext(:,i) = [1;1;1;1];
        end
    end
    shapeHistContext = phog(im, bboxContext);

    %L1-normalization
    wordHistContext = bsxfun(@times, wordHistContext, 1./(sum(wordHistContext)+eps));
    colorHistContext = bsxfun(@times,colorHistContext,1.0./(sum(colorHistContext)+1e-10));
    locHistContext = bsxfun(@times,locHistContext,1.0./(sum(locHistContext)+1e-10));
    shapeHistContext = bsxfun(@times,shapeHistContext,1.0./(sum(shapeHistContext)+1e-10));
    descrsContext = [wordHistContext;colorHistContext;locHistContext;shapeHistContext];
    
    save(outputfile, 'descrs', 'bboxes','descrsContext', 'bboxContext');
    fprintf('Processing %d image in %f seconds.\n', f, toc);
    
end