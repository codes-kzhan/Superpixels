% Optical Flow Based Superpixel Benchmark
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
% main_segmentKitti(alg_paramfilename, kitti_paramfilename, replaceFlag)
% 
% Segment and store Kitti images. Paths are controlled by the input parameter 
% file and set_paths.m 
%
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% kitti_paramfilename ... dataset parameter file (YAML)
% replaceFlag ... overwrite results if already exist (default 1)
%
function main_segmentKitti(alg_paramfilename, kitti_paramfilename, replaceFlag)

    if ~exist('replaceFlag','var'), replaceFlag=1; end

    fprintf('main_segmentKitti: %s and %s\n', alg_paramfilename, kitti_paramfilename);

    % set_paths
    set_paths;
    
    % parse parameter file
    params = ReadYaml(alg_paramfilename);
    kitti_params = ReadYaml(kitti_paramfilename);
    addpath(params.segParams.path);
    
    % get paths to images
    kitti = getKittiImage(kitti_params.kittiPath, kitti_params.nImagePairs);    
    
    for s=1:numel(params.segParams.set)
        fprintf('\tWorking on paramset: %s\t', params.segParams.set{s}.name);
        
         % create result folder
        mkdirCheck(fullfile(params.segSaveDir,...
                       kitti_params.id, ...
                       params.id, ...
                       params.segParams.set{s}.name));

        reverseStr = [];
        for i = 1:numel(kitti)
            reverseStr = printProgress('(Image pair %d of %d)\n', i, numel(kitti), reverseStr);

            idx = kitti(i).idx;

            %% FIRST IMAGE
            savepath1 = fullfile(params.segSaveDir, ...
                                kitti_params.id, ...
                                params.id, ...
                                params.segParams.set{s}.name, ...
                                sprintf('%06d_10.png', idx));    
            
            % skip if image already exists
            if ~replaceFlag && exist( savepath1, 'file' )
              % do nothing
            else                          
                              
              I = imread(kitti(i).filename0);

              % segment: compute L and t from I
              eval(params.segParams.segFct);

              % save
              imwrite(L, savepath1);
            end
            
            %% SECOND IMAGE
            savepath2 = fullfile(params.segSaveDir, ...
                                kitti_params.id, ...
                                params.id, ...
                                params.segParams.set{s}.name, ...
                                sprintf('%06d_11.png', idx));      
            % skip if image already exists
            if ~replaceFlag && exist( savepath2, 'file' )
              % do nothing;
            else                            
                    
              I = imread(kitti(i).filename1);

              % segment: compute L and t from I
              eval(params.segParams.segFct);

              % save
              imwrite(L, savepath2);
            end
        end
    end
end