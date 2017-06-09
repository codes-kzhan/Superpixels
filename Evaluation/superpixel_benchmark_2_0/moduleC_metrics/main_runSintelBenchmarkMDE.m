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
% main_runSintelBenchmarkMDE(paramfilename)
% 
% Load parameter file, load the segmentations (run main_segmentSintel.m first),
% compute the MDE errors and store results. The used flow distance is hard
% coded.
% 
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% sintel_paramfilename ... dataset parameter file (YAML)
%   
function main_runSintelBenchmarkMDE(alg_paramfilename, sintel_paramfilename)
    fprintf('main_runSintelBenchmarkMDE: %s and %s\n', alg_paramfilename, sintel_paramfilename);

    set_paths;

    % parse parameter file
    params = ReadYaml(alg_paramfilename);
    sintel_params = ReadYaml(sintel_paramfilename);
    
    % get Sintel image paths to 
    sintel = getSintelImage(sintel_params.sintelPath,...  
                            'nScenes', sintel_params.nSintelScenes, ...
                            'nImagesPerScene', sintel_params.nImagesPerScene, ...
                            'renderType', sintel_params.renderType);
                        
    % prepare result storage
    savebasepath = fullfile(params.segSaveDir, ...
                            sintel_params.id, ...
                            params.id, ...
                            'benchmark_results');
    mkdirCheck(savebasepath);
    
    % for each parameter set
    for s=1:numel(params.segParams.set)
        fprintf('\tWorking on paramset: %s\n', params.segParams.set{s}.name);
        
%         flowD_vec = [1];
%         flowD_vec = [1 2 4 8 16 32];
        flowD_vec = cell2mat(sintel_params.flowD_vec);
        
        % for each evaluation scheme
        for flowD = flowD_vec
            fprintf('\t\tflowD = %d\t', flowD);
            
            % collect error measures
            weightedFlowGradientError_vec = [];
            nSegments_vec = [];
            sumFlowGradients_vec = [];
            nBoundaryPixels_vec = [];
            
            % for each Sintel scene
            reverseStr = [];
            for i=1:numel(sintel)                
                reverseStr = printProgress('(Scene %d of %d)\n', i, numel(sintel), reverseStr);           
                
                % for each image combination possible with flowD
                for idx1 = 1:min(inf,(numel(sintel(i).images)-flowD))
                    idx2 = idx1+flowD;
                    
                    % load segment images
                    savepath1 = fullfile(params.segSaveDir, ...
                                         sintel_params.id, ...
                                         params.id, ...
                                         params.segParams.set{s}.name, ...
                                         sprintf('%s_frame_%04d.png', sintel(i).name, idx1));
                    L1 = imread(savepath1);

                    if flowD == 1
                        L2 = [];
                    else
                        savepath2 = fullfile(params.segSaveDir, ...
                                             sintel_params.id, ...
                                             params.id, ...
                                             params.segParams.set{s}.name, ...
                                             sprintf('%s_frame_%04d.png', sintel(i).name, idx2));
                        L2 = imread(savepath2);
                    end
                    
                    % get flow field F and gradient weights W
                    % for speedup, some intermediate results are stored on
                    % disk at folder file_id_base
                    file_id_base = './tmp/sintel_tmp/';
                    if ~exist(file_id_base, 'file'), mkdir(file_id_base); end                    
                    file_id = [file_id_base sintel(i).name '_' num2str(idx1) '_' num2str(idx2) '.mat'];
                    if exist(file_id, 'file')
                        load(file_id); % load F and W
                    else                        
                        [U V valid occluded] = getCombinedFlowField(SINTEL_PATH, sintel(i).name, idx1, idx2);
                        F = cat(3, U, V, valid, occluded);
                        W = getFlowGradientWeights(F,1);
                        save(file_id, 'F', 'W');
                    end

                    % evaluate label images    
                    [weightedFlowGradientError sumFlowGradients nBoundaryPixels] = getFlowErrorMDE(L1, F, L2, W);
                    
                    % store
                    weightedFlowGradientError_vec = [weightedFlowGradientError_vec weightedFlowGradientError];                   
                    nSegments_vec = [nSegments_vec max(L1(:))];
                    sumFlowGradients_vec = [sumFlowGradients_vec sumFlowGradients];
                    nBoundaryPixels_vec = [nBoundaryPixels_vec nBoundaryPixels];
                    
                end % idx1
            end % i        
                            
            savepath = fullfile(savebasepath, sprintf('weightedFlowGradientError-%s-d%d.mat', params.segParams.set{s}.name, flowD));
            save(savepath, 'weightedFlowGradientError_vec', 'nSegments_vec', 'sumFlowGradients_vec', 'nBoundaryPixels_vec');
                        
        end % flowD
        
    end % parameter set s
    
end