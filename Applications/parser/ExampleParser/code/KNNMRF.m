clear all;
close all;
RunSystemMake3D;

visualize = true;
kernel = 'Inters'; % kernel for comparing superpixel descriptors
K = 40; %# of retrieval images
knn = 7; % # of k nearest neighbors for segment classification
alpha = 6; % parameter for MRF pairwise term

load(coocDir);
load(gistDir);
load(['Vocabs/colorVocab' num2str(szColorVocab) '.mat']);
load(['Vocabs/siftVocab' num2str(szSiftVocab) '.mat']);


for i = 1:length(testList)
    
    i
    tic
    query = testList{i};
    
    imfile = ['../datasets/Make3D/Test/Images/' query '.jpg'];
    im = imread(imfile);

    % image retrieval
    RetrieveExamples;
        
    % superpixel classification
    ClassifySuperpixels;

    % infer labels by MRF
    InferMRF;
    save([outputDir query '.mat'],'predictLabel');
    toc;
    
    % visualize
    if visualize
        draw_label_image(im/255, predictLabel, palette, ['unlabeled',classes]);
        print([outputDir, query, '.png'],'-dpng','-r96');
    end
        
    disp('please enter any key to continue');
    pause;
    close all;
    
end

