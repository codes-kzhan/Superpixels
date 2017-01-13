% Run System
warning off;
addpath(genpath('Gist'));
addpath(genpath('phog'));
addpath(genpath('util'));
addpath(genpath('liblinear-1.8'));
addpath(genpath('LLC'));
addpath(genpath('graphcut'));
addpath(genpath('segment'));
addpath(genpath('vlfeat-0.9.13'));
vl_setup;

NC = 7;
palette = [[0 0 0]; colormap(jet(NC))]; close;
% load('ColorMatching/objcolormap.mat');
% palette = objcolormap;
% load('output/SIFTflow/palette.mat');
% palette = palette./255;
% palette = [[0 0 0];palette];
szSiftVocab = 1024;
szColorVocab = 128;
kvalues = 50;

imDir = '../datasets/Make3D/Training/Images/';
labelDir = '../datasets/Make3D/Training/Labels/';

trainList = textread('../datasets/Make3D/trainList.txt','%s');
for f = 1:length(trainList)
    trainList{f} = trainList{f}(1:end-4);
end
testList = textread('../datasets/Make3D/testList.txt','%s');
for f = 1:length(testList)
    testList{f} = testList{f}(1:end-4);
end

load([labelDir trainList{1} '.mat']);
classes = names;
clear S;

outputDir = '../output/Make3D/';
if ~isdir(outputDir)
    mkdir(outputDir);
end

gistDir = '../output/Make3D/GistDatabase.mat';
coocDir = '../output/Make3D/cooc.mat';

siftDir = '../output/Make3D/sifts/';
if ~isdir(siftDir)
    mkdir(siftDir);
end

scodeDir = '../output/Make3D/scodes/';
if ~isdir(scodeDir)
    mkdir(scodeDir);
end

descrDir = ['../output/Make3D/descrs/'];
if ~isdir(descrDir)
    mkdir(descrDir);
end

segDir = ['../output/Make3D/segs/'];
if ~isdir(segDir)
    mkdir(segDir);
end

gtDir = ['../output/Make3D/gts/'];
if ~isdir(gtDir)
    mkdir(gtDir);
end

gtsegDir = ['../output/Make3D/gtsegs/'];
if ~isdir(gtsegDir)
    mkdir(gtsegDir);
end

outputDir  = ['../output/Make3D/results/'];
if ~isdir(outputDir)
    mkdir(outputDir);
end

