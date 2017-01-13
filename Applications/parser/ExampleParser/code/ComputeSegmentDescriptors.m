% compute features (sift histogram, color histogram, location, shape)

N = length(trainList);
xLocZones = 6;
yLocZones = 6;
llcK = 5;
load(['Vocabs/colorVocab' num2str(szColorVocab) '.mat']);
load(['Vocabs/siftVocab' num2str(szSiftVocab) '.mat']);
se = strel('diamond', 10);
tic;
for f = 1:N
    
    name = trainList{f};
%     found = strfind(name, '/');
%     subdir = name(1:found(end));
%     if ~isdir([descrDir,subdir])
%         mkdir([descrDir,subdir]);
%     end
    imfile = [imDir name '.jpg'];
    
    outputfile = [descrDir name '.mat'];
    if exist(outputfile,'file')
        continue;
    end
    
    im = imread(imfile);
    if size(im,3)<=1
        im = cat(3,im,im,im);
    end
    [bh, bv] = phogGradients(im);
    
    load([segDir name '.mat']);
    load([siftDir name '.mat']);
    load([scodeDir name '.mat']);
    
    descrs = cell(1,length(baseRegions));
    bboxes = cell(1,length(baseRegions));
    descrsContext = cell(1,length(baseRegions));
    bboxesContext = cell(1,length(baseRegions));
    for kk = 1:length(baseRegions),
        %computing sift histograms for base regions
        loc = sub2ind(imsize, round(frames(2,:)'), round(frames(1,:)'));
        regions = baseRegions{kk}(loc);
        regions = repmat(regions', [llcK 1]);
        wordIndex = (regions-1)*size(siftVocab,2)+ix;
        wordHist = accumarray(wordIndex(:),w(:),[nBaseRegions(kk)*size(siftVocab,2) 1],@sum);
        wordHist = reshape(wordHist,[size(siftVocab,2) nBaseRegions(kk)]);

        %computing color histograms for base regions
        colors = reshape(shiftdim(im,2),[3 size(im,1)*size(im,2)]);
        colors = vl_ikmeanspush(colors,colorVocab);
        colorHist = accumarray([colors(:) baseRegions{kk}(:)],...
           ones(numel(colors),1), [size(colorVocab,2) nBaseRegions(kk)]);

        %computing location histograms for base regions
        [y x] = ndgrid(1:size(im,1),1:size(im,2));
        y = ceil(y/size(im,1)*yLocZones);
        x = ceil(x/size(im,2)*xLocZones);
        locations = (y-1)*xLocZones+x;
        locHist = accumarray([locations(:) baseRegions{kk}(:)],...
           ones(numel(locations),1), [xLocZones*yLocZones nBaseRegions(kk)]);       

        %computing shape histograms for base regions
        bboxes{kk} = zeros(4,nBaseRegions(kk));
        for i = 1:nBaseRegions(kk)
            mask = (baseRegions{kk} == i);
            rangx = find(sum(mask,1));  
            rangy = find(sum(mask,2));
            minx = rangx(1); maxx = rangx(end);
            miny = rangy(1); maxy = rangy(end);
            bboxes{kk}(:,i) = [minx;miny;maxx;maxy];
        end
        shapeHist = phog2(bh, bv, bboxes{kk});

        %L1-normalization
        wordHist = bsxfun(@times, wordHist, 1./(sum(wordHist)+eps));
        colorHist = bsxfun(@times,colorHist,1.0./(sum(colorHist)+1e-10));
        locHist = bsxfun(@times,locHist,1.0./(sum(locHist)+1e-10));
        shapeHist = bsxfun(@times,shapeHist,1.0./(sum(shapeHist)+1e-10));
        
        descrs{kk} = single([wordHist;colorHist;locHist;shapeHist]);

        %compute context features
        wordHistContext = zeros(size(siftVocab,2), nBaseRegions(kk),'single');
        colorHistContext = zeros(size(colorVocab,2), nBaseRegions(kk),'single');
        locHistContext = zeros(xLocZones*yLocZones, nBaseRegions(kk),'single');
        bboxesContext{kk} = zeros(4,nBaseRegions(kk));
        for i = 1:nBaseRegions(kk)
            mask = (baseRegions{kk} == i);
            mask = imdilate(mask, se);
            rangx = find(sum(mask,1));  
            rangy = find(sum(mask,2));
            minx = rangx(1); maxx = rangx(end);
            miny = rangy(1); maxy = rangy(end);
            bboxesContext{kk}(:,i) = [minx;miny;maxx;maxy];
            validLoc = mask(loc);
            subIndex = ix(:,validLoc>0);
            subCoeff = w(:,validLoc>0);
            wordHistContext(:,i) = accumarray(subIndex(:),subCoeff(:),[size(siftVocab,2) 1],@max);
            subColors = colors(:,mask>0);
            colorHistContext(:,i) = accumarray(subColors(:),ones(numel(subColors),1), [size(colorVocab,2) 1]);
            subLocations = locations(mask>0);
            locHistContext(:,i) = accumarray(subLocations(:),ones(numel(subLocations),1), [xLocZones*yLocZones 1]); 
        end
        shapeHistContext = phog2(bh, bv, bboxesContext{kk});

        %L1-normalization
        wordHistContext = bsxfun(@times, wordHistContext, 1./(sum(wordHistContext)+eps));
        colorHistContext = bsxfun(@times,colorHistContext,1.0./(sum(colorHistContext)+1e-10));
        locHistContext = bsxfun(@times,locHistContext,1.0./(sum(locHistContext)+1e-10));
        shapeHistContext = bsxfun(@times,shapeHistContext,1.0./(sum(shapeHistContext)+1e-10));
        descrsContext{kk} = single([wordHistContext;colorHistContext;locHistContext;shapeHistContext]);
    end
    
    save(outputfile, 'descrs', 'bboxes','descrsContext', 'bboxesContext');
    fprintf('Superpixel descriptors: %d image in %f seconds.\n', f, toc);
    
end
