% segmentaion by FH
tic;
for f = 1:numel(trainList)
    
    name = trainList{f};
    outputfile = [gtsegDir name '.mat'];
    if exist(outputfile,'file')
        continue;
    end   

    imfile = [imDir name '.jpg'];
    I = imread(imfile);
    
    load([labelDir name '.mat']);
    [baseRegions, xLabels] = generate_gt_segments(S, 100);

    if false
        boundaries = zeros(size(baseRegions));
        boundaries(2:end, :) = boundaries(2:end, :) + (baseRegions(2:end, :) ~= baseRegions(1:end-1, :));
        boundaries(:, 2:end) = boundaries(:, 2:end) + (baseRegions(:, 2:end) ~= baseRegions(:, 1:end-1));

        overlayed = im2double(I) + cat(3,0*boundaries,1*boundaries,0*boundaries);
        overlayed(overlayed>1) = 1;
        imshow(overlayed);
        pause;
    end
    save(outputfile, 'baseRegions','xLabels');
    
    if mod(f,100)==0
        fprintf('GT Segment: %d image in %f seconds.\n', f, toc);
    end
end