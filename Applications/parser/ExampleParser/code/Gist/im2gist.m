function g = im2gist(im,param)

if nargin < 2
    % Default parameters
    param.imageSize = 128;
    param.orientationsPerScale = [8 8 8 8];
    param.numberBlocks = 4;
    param.fc_prefilt = 4;
end
param.G = createGabor(param.orientationsPerScale, param.imageSize);

if size(im,3) >1
    im = rgb2gray(im);
end
img = single(im);

% resize and crop image to make it square
if ~all(size(im)==param.imageSize)
    img = imresizecrop(img, param.imageSize, 'bilinear');
end

% scale intensities to be in the range [0 255]
img = img-min(img(:));
img = 255*img/max(img(:));

% prefiltering: local contrast scaling
output    = prefilt(img, param.fc_prefilt);

% get gist:
g = gistGabor(output, param.numberBlocks, param.G);

