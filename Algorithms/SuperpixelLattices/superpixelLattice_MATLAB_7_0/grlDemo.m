function grlDemo
% GRLDEMO versn 0.1 win32 MATLAB 7.0 - stable but very little error checking!
% Code updates and bug fixes can be found at: http://pvl.cs.ucl.ac.uk/
%
% *** This program is distributed in the hope that it will be useful, but
% *** WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% *** or FITNESS FOR A PARTICULAR PURPOSE.
%
% Function to demostrate use of mex code for generating a greedy regular
% lattice using new implementation of algorithm presented in:
%
% A. P. Moore, S. J. D. Prince, J. Warrell, U. Mohammed and G. Jones,
% "Superpixel Lattices", CVPR 2008.
%
% The input for the algorithm is a boundary map - an estimate at each pixel
% of the occurence of a natural boundary. For instance this can be the
% binary output of an edge detector or the weighted output
% of the a boundary classification algorithm eg. BEL or Pb.
% 
% The boundary cost map (bndCostMap) is just the inverse of this so that
% minimum paths occur at places of maximum boundary strenght. 
% The algorithm has 5 inputs. USAGE: 
%
% [SUPERPIXELS PATHS]= GRL(BNDCOSTMAP,NUMH,NUMV,BORDERWIDTH,TORTUOSITY,OVERLAP);
% 
% BNDCOSTMAP - boundary strength image m x n
% NUMH - number of superpixels in rows of lattice  [2-40]
% NUMV - number of superpixels in columns of lattice [2-40]
% BORDERWIDTH - number of pixels used to pad each path [1-3]
% TORTUOSITY - constant removed from edges perpendicular to path [0-100]
% OVERLAP - the ammount of overlap between image strips [0-1]
%
% 
% Parameters include:
% 
%       'bndCostMap'    -  An estimate the boudnary at a given pixel 
%                          and should be scaled between 0 and 255. 
% 
%       'numH' & 'numV' -  Together these specify the resolution of 
%                          the lattice. For instance 25x25=625 superpixles.
%                          There is currently no error checking for sensible values! 
%
%       'borderWidth'   -  This specifies the ammount of padding around the
%                          chosen path - experiment - but you probably dont
%                          want to set this much above 1. For instance this
%                          prevents paths following the same boundary in an
%                          image, where the boundary estimate is smoothed over
%                          several pixels.
%
%       'tortuosity'    -  A constant to be removed perpendicular to the orientation
%                          of the path. For instance in a horizontal strip a value of
%                          255 will remove all vertical boundary weights and therefore
%                          produce a very tortuous path. Note that it has not been fully
%                          debugged so values from 0-100 are hoepefully sensible for
%                          generating a superpixelLattice with the correct properties.
%
%       'overlap'       -  A constant that specifies the overlap between strips used in
%                          the greedy construction of the lattice. Sensible values are
%                          from 0-1 i.e. 0.1 is a ten percent overlap.
%
% Returns:
%      
%       'superpixels'   -  An index image from 1:numH*numV in column major
%                          order. For instance imshow(superPixels==1)
%                          displays first superpixel. 
%
%       'paths'         -  A 1x(numH+numV-2) cell array containing the column major linear
%                          index for each pixel in the paths in the order in which they were chosen. 
%      
% Example:
%   
%       bndMap = imread('42049_BEL.tif');
%       bndCostMap = 255-double(bndMap);
%       superPixels = grl(bndCostMap,25,25,1,80,0.4);

clear, close all, clc; %#ok<DUALC>

%% read in test image
%  David Martin, Charless Fowlkes and Jitendra Malik,"Learning to Detect 
%  Natural Image Boundaries Using Local Brightness, Color and Texture
%  Cues", PAMI,26(5), 530-549, May 2004.
%  http://www.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/segbench/
%
img = imread('42049.tif');

%% read in bndMap BEL image if required
%   P. Dollr, Z. Tu, and S. Belongie. Supervised learning of edges
%   and object boundaries. CVPR, 2:1964?971, 2006.
%   http://vision.ucsd.edu/~pdollar/research/research.html
%
bndMap = imread('42049_BEL.tif');

%% simple example bndMap using Matlab Image Processing Toolbox
% find edges
%bndMap = edge(img,'canny').*255;

% set up cost map - cost is low (min cost path) where bndMap is high
bndCostMap = 255-double(bndMap);

% set parameters
numH = 25;
numV = 25;
borderWidth = 1;
tortuosity = 80;
overlap = 0.4;

% run greedy regular lattice
fprintf('Greedy Regular Lattice completed:\n');
tic;
[superPixels, paths] = grl(bndCostMap,numH,numV,borderWidth,tortuosity,overlap);
toc;

% different vizualizations
vizOne(img,superPixels,paths);
vizTwo(bndCostMap,superPixels,paths);
vizThree(img,superPixels,paths);
vizFour(img,superPixels,paths);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Vizualization One
% red boundaries over original image
function vizOne(img,sp,paths)
    
figure, imshow(img);
[nRows mCols] = size(img);
hold on
for i = 1:length(paths)
    path = paths{i}+1;
    [y x] = ind2sub([nRows mCols],path);
    plot(x,y,'Color',[1 0 0],'LineWidth',3);
end
title('Red Superpixel Boundaries - Original Image');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Vizualization Two
% display cost map with randomly coloured greedy regular lattice
function vizTwo(img,sp,paths)

img = (img-min(img(:)))./(max(img(:))-min(img(:)));
figure,imshow(img);
[nRows mCols] = size(img);
cmap = hsv(length(paths));
idx = randperm(length(paths));
hold on
for i = 1:length(paths)
    path = paths{i}+1;
    [y x] = ind2sub([nRows mCols],path);
    plot(x,y,'Color',cmap(idx(i),:),'LineWidth',3);
end
title('Randomly Coloured Greedy Regular Lattice');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Vizualization Three
% 'stain glass' display mean of each superpixel 'jet' colour map with black boundaries
function vizThree(img,sp,paths)

[nRows mCols] = size(img);
figure,imshow(label2rgb(sp,'jet','w','shuffle')); 
hold on
for i = 1:length(paths)
    path = paths{i}+1;
    [y x] = ind2sub([nRows mCols],path);
    plot(x,y,'Color',[0 0 0],'LineWidth',3);
end
title('Black Superpixel Boundaries - Random Superpixel Colur');

%% Vizualization Four
% display mean of each superpixel with black boundaries
function vizFour(img,sp,paths)

[nRows mCols] = size(img);
spMean = zeros(nRows,mCols);

for i = 1:sp(end)   
    pixList = find(sp==i);
    meanPix = mean(double(img(pixList)));
    spMean(pixList) = meanPix;
end

spMean = (spMean-min(spMean(:)))./(max(spMean(:))-min(spMean(:)));
figure,imshow(spMean)
hold on
for i = 1:length(paths)
    path = paths{i}+1;
    [y x] = ind2sub([nRows mCols],path);
    plot(x,y,'Color',[0 0 1],'LineWidth',3);
end
title('Blue Superpixel Boundaries - Mean Superpixel Value');
