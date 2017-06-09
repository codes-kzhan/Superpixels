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
% main_segmentBSDS(alg_paramfilename, bsds_paramfilename, replaceFlag)
%
% Load benchmark parameter file and run its algorithm and parameter
% setting. Results are stored to disk.
%
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% bsds_affine_paramfilename ... dataset parameter file (YAML)
% replaceFlag ... overwrite results if already exist (default 1)
%
function main_segmentBSDS(alg_paramfilename, bsds_paramfilename, replaceFlag)
    
    if ~exist('replaceFlag','var'), replaceFlag=1; end

    fprintf('main_segmentBSDS: %s and %s\n', alg_paramfilename, bsds_paramfilename);

    set_paths;

    % parse parameter file
    params = ReadYaml(alg_paramfilename);
    bsds_params = ReadYaml(bsds_paramfilename);
    addpath(params.segParams.path);
    
    %% load benchmark images (images and their names)
    fprintf('\t'); 
    [images, ~, names] = loadBSDS500(bsds_params.BSDS500_root, bsds_params.mode, bsds_params.nImages);
    
    %% process each parameterset (run algorithm and process runtime computation)
    for s=1:numel(params.segParams.set)
        fprintf('\tWorking on paramset: %s\t', params.segParams.set{s}.name);
        
        % create result folder
        savePathBase =  fullfile(params.segSaveDir, bsds_params.id, params.id, params.segParams.set{s}.name); 
        mkdirCheck(savePathBase);
      
        % ===== run algorithm ===
        reverseStr = [];
        for i=1:length(images)
            reverseStr = printProgress('(Image %d of %d)\n', i, length(images), reverseStr);
            
            % skip if image already exists
            if ~replaceFlag && exist( fullfile(savePathBase, sprintf([(names{i}) '.png'])), 'file' )
              continue;
            end
                      
            I = images{i};        
              
            % segment: compute L and t from I
            eval(params.segParams.segFct);

            % save image
            imwrite(L, fullfile(savePathBase, sprintf([(names{i}) '.png'] )));
            
            % save time
            save(fullfile(savePathBase, [(names{i}) '_time.mat']), 't');
        end
        
        % ===== load all times, build runtimes matrix and store in runtimes.mat ====
        % storage for algorithm run times alg_times(i) is time for image i 
        alg_times = zeros(length(images),1); 
        for i=1:length(images)
            % load time of image i
            load_time = load(fullfile(savePathBase, [(names{i}) '_time.mat']), 't');
            
            % append to alg_times
            alg_times(i) = load_time.t;
        end
        
        % save times
        savePathTimes = fullfile(savePathBase, 'runtimes');    
        save(savePathTimes, 'alg_times');
        
        
    end

    
    
end