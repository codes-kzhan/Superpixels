% Superpixel Benchmark
% Copyright (C) 2015  Peer Neubert, peer.neubert@etit.tu-chemnitz.de
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% -------------------------------------
%
% main_runBenchmarkBSDS(alg_paramfilename, bsds_paramfilename)
%
% Load benchmark parameter file and run its benchmark setting(s).
% This function loads the results of a prior run of runAlgorithm and
% computes the error metrics. Results are stored to disk at the location
% specified in the bpf-file
%
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% bsds_paramfilename ... dataset parameter file (YAML)
%
function main_runBenchmarkBSDS(alg_paramfilename, bsds_paramfilename)
    fprintf('main_runBenchmarkBSDS: %s and %s\n', alg_paramfilename, bsds_paramfilename);

    % parse parameter file
    params = ReadYaml(alg_paramfilename);
    bsds_params = ReadYaml(bsds_paramfilename);
    
    % load benchmark images (images and their names)
    fprintf('\t'); 
    [images, gt, names] = loadBSDS500(bsds_params.BSDS500_root, bsds_params.mode, bsds_params.nImages);
        
    % for each parameterset 
    for s=1:numel(params.segParams.set)        
        fprintf('\tWorking on paramset: %s\t', params.segParams.set{s}.name);
        n = length(images);
        
        % prepare storage
        imName = zeros(n,1);
        imNSegments = zeros(n,1);
        imRecall = zeros(n,1);
        imPrecision = zeros(n,1);
        
        loadPathBase =  fullfile(params.segSaveDir, bsds_params.id, params.id, params.segParams.set{s}.name);             
        
        % for each image
        reverseStr = [];
        for i=1:n
            reverseStr = printProgress('(Image %d of %d)\n', i, length(images), reverseStr);
            
            % load algorithm result 
            loadPath = fullfile(loadPathBase, sprintf([(names{i}) '.png'] ));
            S = imread(loadPath);
            
            % create boundary image from segment image
            B = multiLabelImage2boundaryImage(S);
            
            % Benchmark
            
            % TP FP TN FN
            combinedGTBim = combineMultipleBoundaryImages(gt{i}.groundTruth);
            [imTP imFP imTN imFN] = compareBoundaryImagesSimple(B, combinedGTBim, 2);
            recall = imTP/(imTP+imFN);
            precision = imTP/(imTP+imFP);
            
            % number of segments
            nSegments = max(S(:));
            
            % undersegmentation error
            sumUndersegError = 0;
            sumUndersegErrorTP = 0;
            sumUndersegErrorSLIC = 0;
            for j=1:length(gt{i}.groundTruth)
                [undersegError, undersegErrorTP, undersegErrorSLIC] = getUndersegmentationError(S, gt{i}.groundTruth{j}.Segmentation);
                sumUndersegError = sumUndersegError + undersegError;
                sumUndersegErrorTP = sumUndersegErrorTP + undersegErrorTP;
                sumUndersegErrorSLIC = sumUndersegErrorSLIC + undersegErrorSLIC;     
            end
            undersegError = sumUndersegError/length(gt{i}.groundTruth);
            undersegErrorTP = sumUndersegErrorTP/length(gt{i}.groundTruth);
            undersegErrorSLIC = sumUndersegErrorSLIC/length(gt{i}.groundTruth);
            
            
            % store result for this image
            imName(i) = str2double(names{i});
            imNSegments(i) = nSegments;
            imRecall(i) = recall;
            imPrecision(i) = precision;
            imUnderseg(i) = undersegError;
            imUndersegTP(i) = undersegErrorTP;
            imUndersegSLIC(i) = undersegErrorSLIC;
        end
        
        % load runtimes
        loadPath =  fullfile(loadPathBase, 'runtimes.mat');   
        if exist(loadPath, 'file')
            runtimes = load(loadPath);
            imRuntime = runtimes.alg_times;

            % store to disk
            savePath =  fullfile(loadPathBase, 'benchmarkResult.mat'); 
            save(savePath, 'imName', 'imNSegments', 'imRecall', 'imPrecision', 'imUnderseg', 'imUndersegTP', 'imUndersegSLIC', 'imRuntime');
        else          
            % store to disk
            savePath =  fullfile(loadPathBase, 'benchmarkResult.mat'); 
            save(savePath, 'imName', 'imNSegments', 'imRecall', 'imPrecision', 'imUnderseg', 'imUndersegTP', 'imUndersegSLIC');
        end
            
    end
    
end