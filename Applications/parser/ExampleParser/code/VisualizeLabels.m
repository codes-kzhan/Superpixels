clear all;
close all;
RunSystemMake3D;
stage = 1;

for i = 1:length(testList)
    
    i
    query = testList{i};
    imfile = [imDir query '.jpg'];
    im = imread(imfile);
    
    % convert labels
    load([outputDir query '_' num2str(stage) '.mat']);
    draw_label_image(predictLabel, palette, ['unlabeled',classes]);
    labelstr = [outputDir query, '_' num2str(stage) '.png'];
    print(labelstr,'-dpng','-r96');
    
%         figure; imshow(im);     

%     pause;
    close all;
    
end

