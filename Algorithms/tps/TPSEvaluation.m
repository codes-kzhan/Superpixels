clear all;
close all;
numbers = 900;

datasetPath = '~/SuperpixelBenchmark/data/images/';
filenames = dir(fullfile(datasetPath,'*.jpg'));
[rows, columns] = size(filenames);

totalTime = 0;

for i = 1:rows;
    img = imread(strcat([datasetPath,filenames(i).name]));
    [ height width channel ] = size(img);
    H_num = round(sqrtm((numbers*width)/height));
    W_num = round(sqrtm((numbers*height)/width));
    [edge_map, temp1] = pbCGTG(im2double(img));
    edge_map(edge_map < 0.05)=0;
    
    tic
    [superpixel_label superpixel_map] = Get_Regular_SP( img, edge_map, H_num,W_num );
    time = toc;
    totalTime = totalTime + time;
end
averageTime = totalTime/rows