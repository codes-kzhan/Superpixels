%VOCEVALSEG Evaluates a set of segmentation results.
% VOCEVALSEG(VOCopts,ID); prints out the per class and overall
% segmentation accuracies. Accuracies are given using the intersection/union 
% metric:
%   true positives / (true positives + false positives + false negatives) 
%
% [ACCURACIES,AVACC,CONF] = VOCEVALSEG(VOCopts,ID) returns the per class
% percentage ACCURACIES, the average accuracy AVACC and the confusion
% matrix CONF.
%
% [ACCURACIES,AVACC,CONF,RAWCOUNTS] = VOCEVALSEG(VOCopts,ID) also returns
% the unnormalised confusion matrix, which contains raw pixel counts.
% clear all;
% close all;
RunSystemMake3D;
stage = 1;

% number of labels = number of classes plus one for the background
num = NC;
confcounts = zeros(num);
count=0;
tic;
for i=1:length(testList)
    % display progress
    if toc>1
        fprintf('test confusion: %d/%d\n',i,length(testList));
        drawnow;
        tic;
    end
        
    imname = testList{i};
    
    % ground truth label file
    load([labelDir imname '.mat']);
    gtim = double(S);
    
    % results file
    load([outputDir imname '_' num2str(stage) '.mat']);
%     load([outputDir imname '.mat']);
%     load(['../../Downloads/Tighe/SIFTflow/results/' imname '.mat']);
    resim = double(predictLabel);
    
    % Check validity of results image
    maxlabel = max(resim(:));
    if (maxlabel>NC), 
        error('Results image ''%s'' has out of range value %d (the value should be <= %d)',imname,maxlabel,NC);
    end

    szgtim = size(gtim); szresim = size(resim);
    if any(szgtim~=szresim)
        error('Results image ''%s'' is the wrong size, was %d x %d, should be %d x %d.',imname,szresim(1),szresim(2),szgtim(1),szgtim(2));
    end
    
    %pixel locations to include in computation
    locs = gtim>0;
    
    % joint histogram
    sumim = gtim+(resim-1)*num; 
    hs = histc(sumim(locs),1:num*num); 
    count = count + numel(find(locs));
    confcounts(:) = confcounts(:) + hs(:);
end

% confusion matrix - first index is true label, second is inferred label
%conf = zeros(num);
conf = 100*confcounts./repmat(1E-20+sum(confcounts,2),[1 size(confcounts,2)]);
rawcounts = confcounts;

% Percentage correct labels measure is no longer being used.  Uncomment if
% you wish to see it anyway
%overall_acc = 100*sum(diag(confcounts)) / sum(confcounts(:));
%fprintf('Percentage of pixels correctly labelled overall: %6.3f%%\n',overall_acc);

accuracies = zeros(NC,1);
fprintf('Accuracy for each class (intersection/union measure)\n');
for j=1:NC
   
   gtj=sum(confcounts(j,:));
   resj=sum(confcounts(:,j));
   gtjresj=confcounts(j,j);
   % The accuracy is: true positive / (true positive + false positive + false negative) 
   % which is equivalent to the following percentage:
   accuracies(j)=100*gtjresj/(gtj+resj-gtjresj+eps);   
   clname = classes{j};
   fprintf('  %14s: %6.3f%%\n',clname,accuracies(j));
end
accuracies = accuracies(1:end);
avacc = mean(accuracies([1:8,10,12:15,17:33]));
accuracies = [accuracies; avacc];
fprintf('-------------------------\n');
fprintf('Average accuracy: %6.3f%%\n',avacc);
h = bar(accuracies);
set(h(1),'FaceColor',[0.2,0.2 1]) % use color name
set(h(2),'FaceColor',[1 0.2 0.2]) % or use RGB triple
t = text(1:NC+1,-1*ones(1,NC+1),[classes,'mean']);
set(t,'HorizontalAlignment','right','VerticalAlignment','top', ...
'Rotation',45, 'FontSize', 20);

% Remove the default labels
set(gca,'XTickLabel','')

