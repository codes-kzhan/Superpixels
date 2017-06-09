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
% main_runBenchmarkSize(alg_paramfilename, bsds_paramfilename)
%
% Load segmentation results and collect statistics about segment sizes.
% 
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% bsds_paramfilename ... dataset parameter file (YAML)
%
function main_runBenchmarkSize(alg_paramfilename, bsds_paramfilename)
      
    fprintf('main_runBenchmarkSize, %s and %s\n', alg_paramfilename, bsds_paramfilename);
    
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
            
            % collect segment sizes 
            segSizes = [];
            nSegs = max(S(:));
            for j=1:nSegs
              nPixel = nnz(S==j);
              if nPixel>0
                segSizes(end+1) = nPixel;
              end
            end
                       
            % number of segments
            nSegments = numel(unique( S(:) ));
            
            % store result for this image
            segmentSizes{i} = segSizes;
            imNSegments(i) = nSegments;
        end
        

        % store to disk
        savePath =  fullfile(loadPathBase, ['benchmarkResultSegmentSizes.mat']); 
        save(savePath, 'segmentSizes', 'imNSegments');
        
            
    end
    
end




