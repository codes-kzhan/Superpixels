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
% main_segmentSintel(alg_paramfilename, sintel_paramfilename, replaceFlag)
% 
% Segment and store Sintel images. Paths are controlled by the input parameter 
% file and set_paths.m 
%
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% sintel_paramfilename ... dataset parameter file (YAML)
% replaceFlag ... overwrite results if already exist (default 1)
%
function main_segmentSintel(alg_paramfilename, sintel_paramfilename, replaceFlag)
    
    if ~exist('replaceFlag','var'), replaceFlag=1; end
    
    fprintf('main_segmentSintel: %s and %s\n', alg_paramfilename, sintel_paramfilename);

    set_paths;

    % parse parameter file
    params = ReadYaml(alg_paramfilename);
    sintel_params = ReadYaml(sintel_paramfilename);
    addpath(params.segParams.path);
        
    % get Sintel images
    sintel = getSintelImage(sintel_params.sintelPath,... 
                            'nScenes', sintel_params.nSintelScenes, ...
                            'nImagesPerScene', sintel_params.nImagesPerScene, ...
                            'renderType', sintel_params.renderType);
    
    addpath(params.segParams.path);
    
    % get total number of images
    n=0;
    for i=1:numel(sintel)
      n = n+numel(sintel(i).images);
    end
    
    % for each parameter set
    for s=1:numel(params.segParams.set)
        fprintf('\tWorking on paramset: %s\t', params.segParams.set{s}.name);
        
        % create result folder
        mkdirCheck(fullfile(params.segSaveDir, sintel_params.id, params.id, params.segParams.set{s}.name));

        % segment each image and store
        reverseStr = [];
        ii=0;
        for i=1:numel(sintel)
            for j=1:numel(sintel(i).images)
                ii=ii+1;
                reverseStr = printProgress('(Image %d of %d)\n', ii, n, reverseStr);           
                
                savepath = fullfile(params.segSaveDir, ...
                                    sintel_params.id, ...
                                    params.id, ...
                                    params.segParams.set{s}.name, ...
                                    sprintf('%s_frame_%04d.png', sintel(i).name, j));
                
                 
                % skip if image already exists
                if ~replaceFlag && exist( savepath, 'file' )
                  continue;
                end
                
                % load image
                I = imread(sintel(i).images(j).path);

                % segment: compute L and t from I
                eval(params.segParams.segFct);

                % save                
                imwrite(L, savepath);
            end
        end
    end
        

end