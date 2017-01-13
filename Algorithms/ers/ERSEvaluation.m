clear all;
close all;
numbers = 900;


datasetPath = '~/SuperpixelBenchmark/data/images/';
filenames = dir(fullfile(datasetPath,'*.jpg'));
[rows, columns] = size(filenames);

totalTime = 0;

for i = 1:rows;
    img = imread(strcat([datasetPath,filenames(i).name]));
    img = double(rgb2gray(img));
    tic
    [labels] = mex_ers(img,numbers);
    time = toc;
    totalTime = totalTime + time;
end
averageTime = totalTime/rows