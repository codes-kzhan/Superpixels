% Matlab code for Topology Preserved Regular Superpixel
%
% Please cite [1] if you used or was inspired by this code/work:
% 
% [1] Dai Tang, Huazhu Fu, Xiaochun, Cao, "Topology Preserved Regular Superpixel," 
% 2012 IEEE International Conference on Multimedia and Expo (ICME), pp.765-768, 2012.
% 
% This code is a primitive MATLAB code, which is simpler than that we used in the paper.
% If you find any bugs, please contact Huazhu Fu (hzfu@tju.edu.cn).
%
clear;
addpath(genpath('segbench'));
path = 'G:\Experiment\images\';
filenames = dir(fullfile(path,'*.jpg'));
[row,columns] = size(filenames);

    for i = 1:row;
        data = imread(strcat(path,filenames(i).name));
        imageName = filenames(i).name;
        img = imread(strcat([path,imageName]));
        [height width channel] = size(img);
        SP_num = 1000; % the number of superpixe
        H_num = round(sqrtm((SP_num*width)/height));
        W_num = round(sqrtm((SP_num*height)/width));

        % gPb edge map.
        [edge_map, temp1] = pbCGTG(im2double(img));
        edge_map(edge_map < 0.05)=0;

        [superpixel_label superpixel_map] = Get_Regular_SP( img, edge_map, H_num,W_num );
    %     label_image_all=(superpixel_map);
    %     se = strel('rectangle',[2 2]);
    %     bw2 = imdilate(uint8(label_image_all),se);
    %     %csvwrite('1.csv',superpixel_label);
    %     img_with_SP=img;
    %     img_with_SP(:,:,1)=(img_with_SP(:,:,1))+ bw2;
    %     img_with_SP(:,:,2)=(img_with_SP(:,:,2))- bw2;
    %     img_with_SP(:,:,3)=(img_with_SP(:,:,3))- bw2;
    %     imwrite(img_with_SP,'result.jpg');
        index = strfind(imageName,'.');
        labelPath = strcat(path,'tps1000',imageName(1:(index-1)),'.csv');
        csvwrite(labelPath,superpixel_label);
    end

% 
% img = imread('48025.jpg');
% [ height width channel ] = size(img);
% 
% SP_num = 400; % the number of superpixel
% H_num = round(sqrtm((SP_num*width)/height));
% W_num = round(sqrtm((SP_num*height)/width));
% 
% gPb edge map.
% [edge_map, temp1] = pbCGTG(im2double(img));
% edge_map(edge_map < 0.05)=0;
%     
% [superpixel_label superpixel_map] = Get_Regular_SP( img, edge_map, H_num,W_num );
% 
% label_image_all=(superpixel_map);
% se = strel('rectangle',[2 2]);
% bw2 = imdilate(uint8(label_image_all),se);
% csvwrite('1.csv',superpixel_label);
% img_with_SP=img;
% img_with_SP(:,:,1)=(img_with_SP(:,:,1))+ bw2;
% img_with_SP(:,:,2)=(img_with_SP(:,:,2))- bw2;
% img_with_SP(:,:,3)=(img_with_SP(:,:,3))- bw2;
% imwrite(img_with_SP,'result.jpg');
% figure,imshow(img_with_SP);


