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
% runBenchmarkAffine(alg_paramfilename, bsds_affine_paramfilename)
%
% Load benchmark parameter file and affine parameter filename and run their
% benchmark setting(s).
% This function loads the results of a prior run of runAlgorithmAffine and
% computes the error metrics. Results are stored to disk at the location
% specified in the parameter files
%
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% bsds_affine_paramfilename ... dataset parameter file (YAML)
%
function main_runBenchmarkBSDS_affine(alg_paramfilename, bsds_affine_paramfilename)
    fprintf('main_runBenchmarkBSDS_affine: %s and %s\n', alg_paramfilename, bsds_affine_paramfilename);

    %% load benchmark parameter files BPF, APF
    params = ReadYaml(alg_paramfilename);
    bsds_affine_params = ReadYaml(bsds_affine_paramfilename);
    
    
    %% load benchmark images (images and their names)
    fprintf('\t'); 
    [images, ~, names] = loadBSDS500( bsds_affine_params.BSDS500_root,...
                                      bsds_affine_params.mode, ...
                                      bsds_affine_params.nImages);
    % for each parameterset 
    for s=1:numel(params.segParams.set)
      
        % skip if this is not the oneShotSet indicated by oneShotSetName
        if ~strcmp(params.segParams.set{s}.name, params.segParams.oneShotSetName)
          continue;
        end
        
        fprintf('\tWorking on paramset: %s\n', params.segParams.set{s}.name);
        
        loadPathBase =  fullfile( params.segSaveDir, ...
                                  bsds_affine_params.id, ...
                                  params.id, ...
                                  params.segParams.set{s}.name);         
        % for each affine set        
        for j=1:length(bsds_affine_params.affine_trafo)
            fprintf('\t\tAffine set %s\t',bsds_affine_params.affine_trafo{j}.name); 
            recall = zeros(bsds_affine_params.nImages, 1);
            precision = zeros(bsds_affine_params.nImages, 1);
            
            % for each image
            reverseStr = [];
            for i=1:length(images)
                reverseStr = printProgress('(Image %d of %d)\n', i, length(images), reverseStr);

                % load original image result and create boundary map
                loadPath = fullfile(loadPathBase, 'original', [(names{i}) '.png']);            
                S_ori = imread(loadPath);
                B_ori = multiLabelImage2boundaryImage(S_ori);
                B_ori = bwmorph(B_ori,'skel',Inf);
                
                % load transformed image result and create boundary map
                loadPath = fullfile(loadPathBase, bsds_affine_params.affine_trafo{j}.name, [(names{i}) '.png']); 
                S_t = imread(loadPath);
                B_t = multiLabelImage2boundaryImage(S_t);
                
                % extra thinning step
                B_t = bwmorph(B_t,'skel',Inf);
                
                % compare: Precision-Recall on boundary image
                [imTP imFP imTN imFN] = compareBoundaryImagesSimple(B_t, B_ori, 2);
                recall(i) = imTP/(imTP+imFN);
                precision(i) = imTP/(imTP+imFP);
                
            end
            % combine results for this affine transformation
            R{j}.name = bsds_affine_params.affine_trafo{j}.name;
            R{j}.parVal = bsds_affine_params.affine_trafo{j}.parVal;
            R{j}.recall = recall;
            R{j}.precision = precision;            
            
        end
           
        % store results for this affine set
        savePath = fullfile(loadPathBase, 'benchmarkAffineResults.mat');
        save(savePath, 'R');
        
    end
    
    fprintf('\n');
 
end