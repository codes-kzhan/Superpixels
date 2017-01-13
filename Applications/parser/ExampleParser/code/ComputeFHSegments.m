% segmentaion by FH
tic
for f = 1:numel(trainList)

    name = trainList{f};
    
    imfile = [imDir name '.jpg'];
    outputfile = [segDir name '.mat'];
    if exist(outputfile,'file')
        continue;
    end   

    I = imread(imfile);
    tempstr = [segDir name '.ppm'];
    imwrite(I, tempstr,'ppm');
    sigma = 0.8;
    min_area = 25;
    baseRegions = cell(length(kvalues),1);
    nBaseRegions = zeros(length(kvalues),1);
    for kk = 1:length(kvalues),
        k = round(kvalues(kk)*max(1,(length(I)/512)^2));
        ma = round(min_area*max(1,(length(I)/512)^2));
        segfile = [segDir name '_k' num2str(k) '_fh.png'];
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
    save(outputfile, 'baseRegions','nBaseRegions');
    if mod(f,100)==0
        fprintf('Segment: %d image in %f seconds.\n', f, toc);
    end
end