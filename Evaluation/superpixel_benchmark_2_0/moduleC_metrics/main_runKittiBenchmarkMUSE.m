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
% main_runKittiBenchmarkMUSE(paramfilename)
% 
% Load parameter file, load the segmentations (run main_segmentKitti.m first),
% compute the MUSE errors and store results.
% 
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% kitti_paramfilename ... dataset parameter file (YAML)
%   
function main_runKittiBenchmarkMUSE(alg_paramfilename, kitti_paramfilename)
    fprintf('main_runKittiBenchmarkMUSE: %s and %s\n', alg_paramfilename, kitti_paramfilename);

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
        undersegError_vec = [];
        nSegments_vec = [];

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

            savepath2 = fullfile(params.segSaveDir, ...
                                 kitti_params.id, ...
                                 params.id, ...
                                 params.segParams.set{s}.name, ...
                                 sprintf('%06d_11.png', idx));
            L2 = imread(savepath2);

            % get flow field
            [U V valid] = kitti_readFlow(kitti_params.kittiPath, idx);
            occluded = 1-valid;
            F = cat(3, U, V, valid, occluded);

            % apply flow on label image    
            L1T = applyFlowTransform(L1, F, 'none');
            L2T = double(L2);
            L2T(occluded~=0) = nan;

            % evaluate label images    
            undersegError = getFlowErrorMUSE(L1T,L2T);
            undersegError_vec = [undersegError_vec undersegError];                   
            nSegments_vec = [nSegments_vec max(L1(:))];
        end % i        

        savepath = fullfile(savebasepath, sprintf('underseg-%s-d1.mat', params.segParams.set{s}.name));
        save(savepath, 'undersegError_vec', 'nSegments_vec');
                        
    end % parameter set s
    
end