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
% main_runSintelBenchmarkMUSE(paramfilename)
% 
% Load parameter file, load the segmentations (run main_segmentSintel.m first),
% compute the MUSE errors and store results.
% 
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% sintel_paramfilename ... dataset parameter file (YAML)
%
function main_runSintelBenchmarkMUSE(alg_paramfilename, sintel_paramfilename)
    fprintf('main_runSintelBenchmarkMUSE: %s and %s\n', alg_paramfilename, sintel_paramfilename);

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
                
        flowD_vec = cell2mat(sintel_params.flowD_vec);
        
        % for each evaluation scheme
        for flowD = flowD_vec
            fprintf('\t\tflowD = %d\t', flowD);
            
            % collect error measures
            undersegError_vec = [];
            nSegments_vec = [];
            
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

                    savepath2 = fullfile(params.segSaveDir, ...
                                         sintel_params.id, ...
                                         params.id, ...
                                         params.segParams.set{s}.name, ...
                                         sprintf('%s_frame_%04d.png', sintel(i).name, idx2));
                    L2 = imread(savepath2);

                    % get flow field
                    [U V valid occluded] = getCombinedFlowField(SINTEL_PATH, sintel(i).name, idx1, idx2);
                    F = cat(3, U, V, valid, occluded);

                    % apply flow on label image    
                    L1T = applyFlowTransform(L1, F, 'none');
                    L2T = double(L2);
                    L2T(occluded~=0) = nan;

                    % evaluate label images    
                    undersegError = getFlowErrorMUSE(L1T,L2T);
                    undersegError_vec = [undersegError_vec undersegError];                   
                    nSegments_vec = [nSegments_vec max(L1(:))];
                    
                    
                end % idx1
            end % i        
                            
            savepath = fullfile(savebasepath, sprintf('underseg-%s-d%d.mat', params.segParams.set{s}.name, flowD));
            save(savepath, 'undersegError_vec', 'nSegments_vec');
                        
        end % flowD
        
    end % parameter set s
    
end