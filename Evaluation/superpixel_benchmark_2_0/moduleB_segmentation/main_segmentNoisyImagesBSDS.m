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
% main_segmentNoisyImagesBSDS(alg_paramfilename, bsds_noise_paramfilename)
%
% Segment the noisy images.
% 
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% bsds_noise_paramfilename ... dataset parameter file (YAML)
function main_segmentNoisyImagesBSDS(alg_paramfilename, bsds_noise_paramfilename)

    fprintf('main_segmentNoisyImagesBSDS: %s and %s\n', alg_paramfilename, bsds_noise_paramfilename);

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
      
      %% process original images      
      reverseStr = [];
      for i=1:length(images)
        reverseStr = printProgress('\tworking on ori image %d of %d\n', i, length(images), reverseStr);

        I = images{i};

        % segment: compute L and t from I 
        %   - input is "I" (color, [0, 255])
        %   - segmentation result is in "L" (integer)
        %   - runtime is stored in"t"
        eval(params.segParams.segFct);

        % save resulting segment image
        savePathBase =  fullfile( noiseParams.noiseImageSaveDir, ... % results
                                  noiseParams.id, ...                % saltAndPepper
                                  params.id, ...                     % watershed
                                  'ori');                            % ori
        mkdirCheck(savePathBase);
        savePath = fullfile(savePathBase, [(names{i}) '.png']);  
        imwrite(L, savePath, 'bitdepth', 16);
      end
      
      %% process all images for each noise parameterset 
      for nIdx=1:numel(noiseParams.noiseSet)

          fprintf('\tWorking on paramset: %s\t', noiseParams.noiseSet{nIdx}.name);

          % create result folder                                       % e.g.
          loadPathBase =  fullfile( noiseParams.noiseImageSaveDir, ... % results
                                    noiseParams.id, ...                % saltAndPepper
                                    'noisy_images', ...                % noisy_images
                                    noiseParams.noiseSet{nIdx}.name);     % d005

          savePathBase =  fullfile( noiseParams.noiseImageSaveDir, ... % results
                                    noiseParams.id, ...                % saltAndPepper
                                    params.id, ...                     % watershed
                                    noiseParams.noiseSet{nIdx}.name);     % d005

          mkdirCheck(savePathBase);

          % for each image        
          reverseStr = [];
          for i=1:length(images)
              reverseStr = printProgress('(working on noisy image %d of %d)\n', i, length(images), reverseStr);

              loadPath = fullfile(loadPathBase, [(names{i}) '.png']);  
              I = imread(loadPath);             

              % segment: compute L and t from I 
              %   - input is "I" (color, [0, 255])
              %   - segmentation result is in "L" (integer)
              %   - runtime is stored in"t"
              eval(params.segParams.segFct);

              % save resulting segment image
              savePath = fullfile(savePathBase, [(names{i}) '.png']);  
              imwrite(L, savePath, 'bitdepth', 16);

          end
      end
    end
    
end

