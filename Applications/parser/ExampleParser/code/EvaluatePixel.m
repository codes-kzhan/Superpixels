clear all;
close all;
RunSystemMake3D;
stage = 1;
GT = cell(length(testList),1);
Y = cell(length(testList),1);
for i = 1:length(testList)
    
    i
    query = testList{i};
    load([outputDir query '_' num2str(stage) '.mat']);
    load([labelDir query '.mat']);
    
%     draw_label_image(predictLabel, palette, ['unlabeled',classes], i, pAcc);
%     labelstr = [outputDir query, '_' num2str(stage) '.png'];
%     print(labelstr,'-dpng','-r96');
%     im = imread([imDir query '.jpg']);
%     imwrite(im,[outputDir query '_im.png']);
%     close;

%     query = trainList{i};
%     load([probDir query '.mat']);
%     [~,predictLabel] = max(Dc,[],3);
%     predictLabel = labelSubset(predictLabel);
%     load([labelDir query '.mat']);
    
    valid = S~=0;
    GT{i} = S(valid);
    Y{i} = predictLabel(valid);
    
end

GT = cell2mat(GT);
Y = cell2mat(Y);

pixelAcc = sum(GT==Y)/length(GT)
accuracies = zeros(NC,1);
for cc = 1 : NC
    if sum(GT==cc)~=0
        accuracies(cc) = sum((GT==Y)&(GT==cc))/sum(GT==cc);
    end
end
avAcc = mean(accuracies)
