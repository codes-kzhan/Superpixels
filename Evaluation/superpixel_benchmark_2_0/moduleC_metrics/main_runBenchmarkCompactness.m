% Superpixel Benchmark
% Copyright (C) 2015 Peer Neubert, peer.neubert@etit.tu-chemnitz.de
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
% main_runBenchmarkCompactness(alg_paramfilename, alg_paramfilename, smoothSize)
%
% Load benchmark parameter file and run its benchmark setting(s).
% This function loads the results of a prior run of runAlgorithm and
% computes the compactness error metric. Results are stored to disk at 
% the location specified in the alg_paramfilename
%
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% bsds_paramfilename ... dataset parameter file (YAML)
% smmothSize ... size of structuring element for smoothing (closing)
%                segment masks for boundary computation
%
function main_runBenchmarkCompactness(alg_paramfilename, bsds_paramfilename, smoothSize)
      
    if ~exist('smoothSize', 'var')
      smoothSize=3;
    end

    fprintf('main_runBenchmarkCompactness, smoothSize=%d: %s and %s\n', smoothSize, alg_paramfilename, bsds_paramfilename);
    
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
        compactness = zeros(n,1);
        imNSegments = zeros(n,1);
        
        loadPathBase =  fullfile(params.segSaveDir, bsds_params.id, params.id, params.segParams.set{s}.name);             
        
        % for each image
        reverseStr = [];
        for i=1:n
            reverseStr = printProgress('(Image %d of %d)\n', i, length(images), reverseStr);
            
            % load algorithm result 
            loadPath = fullfile(loadPathBase, sprintf([(names{i}) '.png'] ));
            S = imread(loadPath);
            
            % Benchmark compactness
            C = getCompactness(S, smoothSize);        
            
            % number of segments
            nSegments = numel(unique( S(:) ));
            
            % store result for this image
            compactness(i) = C;
            imNSegments(i) = nSegments;
        end
        

        % store to disk
        savePath =  fullfile(loadPathBase, ['benchmarkResultCompactness_s' num2str(smoothSize) '.mat']); 
        save(savePath, 'compactness', 'imNSegments');
        
            
    end
    
end




