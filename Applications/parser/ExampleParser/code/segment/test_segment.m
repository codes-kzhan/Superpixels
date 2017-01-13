
segDir = '../LMSun/Superpixels/';
fid = fopen('../../waldo-linux/data/imagelist_LMSun.dat','r'); 
output = fscanf(fid,'%d\n',[2,1]);
resolution = output(1);
nImages = output(2);
imPaths = cell(nImages,1);
for i = 1 : nImages
    tline = fgets(fid);
    imPaths{i} = tline;
end

for i = 1 : numel(imPaths)
    
    i
    imfile = imPaths{i}; %'../VOCdevkit/VOC2012/JPEGImages/2007_000272.jpg ';%
    I = imread(imfile(1:end-1));
    imwrite(I, 'temp.ppm','ppm');
    
    bp = zeros(size(I,1),size(I,2));
    
    for basis_sigma = 0.8
        for basis_min_area = 100%20 : 20 : 60
            for basis_k = 200   
                
                sigma = basis_sigma;
                min_area = basis_min_area;
                k = basis_k*max(1,(length(I)/640)^2);
                segmFileName = 'regions.png';
                % segment image                
                cmd = ['./segment ' num2str(sigma) ' ' num2str(k) ' ' num2str(min_area) ' "' 'temp.ppm' '" "' segmFileName '"' ];      
                tic; system(cmd); toc;
                segments = imread('regions.png');
%                 close all;
                
%                 labels = double(segments(:,:,1))*65536+double(segments(:,:,2))*256+double(segments(:,:,3));
%                 regions = zeros(size(labels));
%                 values = unique(labels);
%                 for ii = 1:length(values)
%                     regions(labels==values(ii)) = ii;
%                 end
                
                found = strfind(imPaths{i}, 'Images');
            	name = imPaths{i}(29:end-5);
                found = strfind(name, '/');
                subdir = name(1:found(end));
                if ~isdir([segDir subdir])
                    mkdir([segDir subdir]);
                end
                segfile = [segDir name '.png'];
                imwrite(segments,segfile, 'png');
%                 figure; imagesc(regions);
%                 figure; imagesc(I);
% 
%                 boundaries = zeros(size(regions));
%                 boundaries(2:end, :) = boundaries(2:end, :) + (regions(2:end, :) ~= regions(1:end-1, :));
%                 boundaries(:, 2:end) = boundaries(:, 2:end) + (regions(:, 2:end) ~= regions(:, 1:end-1));
% 
%                 figure; imagesc(boundaries>0); colormap(gray);
%                 overlayed = im2double(I) + cat(3,boundaries,boundaries,boundaries);
%                 overlayed(overlayed>1) = 1;
%                 figure; imagesc(overlayed);
%                 
%                 bp = bp + double(boundaries);
                
            end
        end
    end
%     bp = bp/max(bp(:));

end