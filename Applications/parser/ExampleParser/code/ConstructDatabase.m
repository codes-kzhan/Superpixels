% Summary of offine operations
close all
clear all;
RunSystemMake3D;

disp('---0.0. Compute GIST image descriptors for retrieval.\n');
ComputeGistDescriptors;

disp('---0.1. Extract SIFT descriptors and their spare codings.\n');
if ~exist(['Vocabs/siftVocab' num2str(szSiftVocab) '.mat'], 'file')
    BuildSIFTVocab;
end
ComputeSIFT;
ComputeSCode;

disp('---0.2. Compute superpixels and their ground truth labels (slow).\n');
ComputeFHSegments;
ComputeGTLabelsFH;

disp('---0.3. Compute ground truth segments and labels for data statistics.\n');
ComputeGTSegments;
ComputeCoocStatistics;

disp('---0.4. Extract superpixel descriptors.\n');
if ~exist(['Vocabs/colorVocab' num2str(szColorVocab) '.mat'])
    BuildColorVocab;
end
ComputeSegmentDescriptors;



