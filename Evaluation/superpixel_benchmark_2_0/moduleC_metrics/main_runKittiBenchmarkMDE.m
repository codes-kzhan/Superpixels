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
% main_runKittiBenchmarkMDE(paramfilename)
% 
% Load parameter file, load the segmentations (run main_segmentKitti.m first),
% compute the MDE errors and store results.
% 
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% kitti_paramfilename ... dataset parameter file (YAML)
%   
function main_runKittiBenchmarkMDE(alg_paramfilename, kitti_paramfilename)
    fprintf('main_runKittiBenchmarkMDE: %s and %s\n', alg_paramfilename, kitti_paramfilename);

    set_paths;

    % parse parameter file
    params = ReadYaml(alg_paramfilename);
    kitti_params = ReadYaml(kitti_paramfilename);
    
    % get KITTI image paths 
    kitti = getKittiImage(kitti_params.kittiPath, kitti_params.nImagePairs);
                        
    % prepare result storage
    savebasepath = fullfile(params.segSaveDir, ...
                            kitti_params.id, ...
                            params.id, ...
                            'benchmark_results');
    mkdirCheck(savebasepath);
                        
    % for each parameter set
    for s=1:numel(params.segParams.set)
        fprintf('\tWorking on paramset: %s\t', params.segParams.set{s}.name);
        
            
        % collect error measures
        weightedFlowGradientError_vec = [];
        nSegments_vec = [];
        sumFlowGradients_vec = [];
        nBoundaryPixels_vec = [];
            

        % for each pair of Kitti images
        reverseStr = [];
        for i=1:numel(kitti)                            
            reverseStr = printProgress('(Image pair %d of %d)\n', i, numel(kitti), reverseStr);
            idx = kitti(i).idx;
            
            % load segment images
            savepath1 = fullfile(params.segSaveDir, ...
                                kitti_params.id, ...
                                params.id, ...
                                params.segParams.set{s}.name, ...
                                sprintf('%06d_10.png', idx));
            L1 = imread(savepath1);

            L2 = [];
            
            % get flow field F and gradient weights W
            % for speedup, some interm,ediate results are store on
            % disk at folder file_id_base
            file_id_base = './tmp/kitti_tmp/';
            if ~exist(file_id_base, 'file'), mkdir(file_id_base); end  
            file_id = [file_id_base 'kitti_' num2str(i) '.mat'];
            if exist(file_id, 'file')
                load(file_id); % load F and W
            else                        
               [U V valid] = kitti_readFlow(kitti_params.kittiPath, idx);
                occluded = 1-valid;
                F = cat(3, U, V, valid, occluded);
                W = getFlowGradientWeights(F,1);
                save(file_id, 'F', 'W');
            end
            
            % get flow field
            [U V valid] = kitti_readFlow(kitti_params.kittiPath, idx);
            occluded = 1-valid;
            F = cat(3, U, V, valid, occluded);

            % evaluate label images    
            [weightedFlowGradientError sumFlowGradients nBoundaryPixels] = getFlowErrorMDE(L1, F, L2, W);
                    
            % store
            weightedFlowGradientError_vec = [weightedFlowGradientError_vec weightedFlowGradientError];                   
            nSegments_vec = [nSegments_vec max(L1(:))];
            sumFlowGradients_vec = [sumFlowGradients_vec sumFlowGradients];
            nBoundaryPixels_vec = [nBoundaryPixels_vec nBoundaryPixels];

        
        end % i        

        savepath = fullfile(savebasepath, sprintf('weightedFlowGradientError-%s-d1.mat', params.segParams.set{s}.name));
        save(savepath, 'weightedFlowGradientError_vec', 'nSegments_vec', 'sumFlowGradients_vec', 'nBoundaryPixels_vec');
                        
    end % parameter set s
    
end