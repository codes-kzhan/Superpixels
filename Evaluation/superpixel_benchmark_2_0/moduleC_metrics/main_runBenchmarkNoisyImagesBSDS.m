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
% main_runBenchmarkNoisyImagesBSDS(alg_paramfilename, bsds_noise_paramfilename)
%
% Run noise benchmark.
% 
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% bsds_noise_paramfilename ... dataset parameter file (YAML)
%
function main_runBenchmarkNoisyImagesBSDS(alg_paramfilename, bsds_noise_paramfilename)

    fprintf('main_runBenchmarkNoisyImagesBSDS: %s and %s\n', alg_paramfilename, bsds_noise_paramfilename);

    %% load benchmark parameter files 
    noiseParams = ReadYaml(bsds_noise_paramfilename);
    params = ReadYaml(alg_paramfilename);
    
    %% load benchmark images (images and their names)
    fprintf('\t'); 
    [images, ~, names] = loadBSDS500( noiseParams.BSDS500_root,...
                                      noiseParams.mode, ...
                                      noiseParams.nImages);
      
    %% process each parameterset (run algorithm)
    for s=1:numel(params.segParams.set)      
      
      % skip if this is not the oneShotSet indicated by oneShotSetName
      if ~strcmp(params.segParams.set{s}.name, params.segParams.oneShotSetName)
        continue;
      end
      
      %% process each noise parameterset 
      for nIdx=1:numel(noiseParams.noiseSet)

          fprintf('\tWorking on paramset: %s\t', noiseParams.noiseSet{nIdx}.name);

          % create result folder                                      % e.g.
          oriPathBase =  fullfile( noiseParams.noiseImageSaveDir, ... % results
                                    noiseParams.id, ...               % saltAndPepper
                                    params.id, ...                    % watershed
                                    'ori');                           % ori

          noisyPathBase = fullfile( noiseParams.noiseImageSaveDir, ...  % results
                                    noiseParams.id, ...                 % saltAndPepper
                                    params.id, ...                      % watershed
                                    noiseParams.noiseSet{nIdx}.name);   % d005

          % load image pairs and compute metrics
          recall = [];
          precision = [];
          meanMaxOverlap = [];
          
          reverseStr = [];
          for i=1:length(images)
            reverseStr = printProgress('(Working on image %d of %d)\n', i, length(images), reverseStr);  
            
            oriPath = fullfile(oriPathBase, [(names{i}) '.png']);  
            noisyPath = fullfile(noisyPathBase, [(names{i}) '.png']);  

            L_ori = imread(oriPath);
            L_noisy = imread(noisyPath);

            % remove zero-labels
            if min(L_ori(:))==0, L_ori=L_ori+1; end
            if min(L_noisy(:))==0, L_noisy=L_noisy+1; end
            
            % compute boundary maps and compare
            B_ori = multiLabelImage2boundaryImage(L_ori);
            B_noisy = multiLabelImage2boundaryImage(L_noisy);
            [imTP, imFP, imTN, imFN] = compareBoundaryImagesSimple(B_noisy, B_ori, 2);
            recall(i) = imTP/(imTP+imFN);
            precision(i) = imTP/(imTP+imFP);
          
            % compare overlap based
            [R, L1t_sizes, L2_sizes] = getOverlap(L_ori, L_noisy, []);
            
            % find subset of segments that should be in both images
            % find all existing labels in F(L1)
            idx = unique(L_ori);
            idx(isnan(idx)) = []; % remove nan

            % find for each valid segment of L1 the maximum overlap to a segment in
            % L2 (minimum overlap error according to ACR paper)
            maxOverlap = [];
            for ii=idx'
              [maxVal, maxIdx] = max( R(ii, :) );
              maxOverlap(end+1) = maxVal;
            end
            meanMaxOverlap(i) = mean(maxOverlap);
            
          end
          
          % save results
          savePath = fullfile(noisyPathBase, 'results.mat');
          save(savePath, 'recall', 'precision', 'meanMaxOverlap');
      end
    end
    
end

