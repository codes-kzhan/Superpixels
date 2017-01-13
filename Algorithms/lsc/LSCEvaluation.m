clear all;
close all;
numbers = 1000;
ratio = 0.075;

datasetPath = '~/SuperpixelBenchmark/data/images/';
filenames = dir(fullfile(datasetPath,'*.jpg'));
[rows, columns] = size(filenames);

totalTime = 0;

for i = 1:rows;
    img = imread(strcat([datasetPath,filenames(i).name]));
    gaus = fspecial('gaussian',3);
    img = imfilter(img,gaus);
    tic
    [labels] = LSC_mex(img,numbers,ratio);
    time = toc;
    totalTime = totalTime + time;
end
averageTime = totalTime/rows