clear all;
close all;
numbers = 1000;
compactness = 20;

datasetPath = '~/SuperpixelBenchmark/data/images/';
filenames = dir(fullfile(datasetPath,'*.jpg'));
[rows, columns] = size(filenames);

totalTime = 0;

for i = 1:rows;
    img = imread(strcat([datasetPath,filenames(i).name]));
    tic
    [labels, numlabels] = slicmex(img,numbers,compactness);
    time = toc;
    totalTime = totalTime + time;
end
averageTime = totalTime/rows
