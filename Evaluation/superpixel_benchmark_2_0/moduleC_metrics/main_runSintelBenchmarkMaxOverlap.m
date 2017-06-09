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
%   
% - uses single shot
% - results are all overlap values for flow_D=1 and a single image pair for
%   each scene. This is similar to the eusipco experiment (to show boxplots
%   of the algorithms next to each other)

function main_runSintelBenchmarkMaxOverlap(alg_paramfilename, sintel_paramfilename)
  fprintf('main_runSintelBenchmarkOverlap: %s and %s\n', alg_paramfilename, sintel_paramfilename);

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

    % skip if this is not the oneShotSet indicated by oneShotSetName
    if ~strcmp(params.segParams.set{s}.name, params.segParams.oneShotSetName)
      continue;
    end

    fprintf('\tWorking on paramset: %s\n', params.segParams.set{s}.name);


    % for each Sintel scene
    reverseStr = [];
    for i=1:numel(sintel)                                 
      reverseStr = printProgress('(Scene %d of %d)\n', i, numel(sintel), reverseStr);           

      % we use only the first image pair of each scene
      idx1 = 1;
      idx2 = 2;


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

      % evaluate label images    
      [R, L1t_sizes, L2_sizes] = getOverlap(L1, L2, F);

      % find subset of segments that should be in both images
      % bring L1 to L2 using flow F, find all existing labels in F(L1)
      L1t = applyFlowTransform(L1, F, 'none');
      idx = unique(L1t);
      idx(isnan(idx)) = []; % remove nan

      % find for each valid segment of L1 the maximum overlap to a segment in
      % L2 (minimum overlap error according to ACR paper)
      maxOverlap = [];
      for ii=idx'
        [maxVal, maxIdx] = max( R(ii, :) );
        maxOverlap(end+1) = maxVal;
      end

    end

    savepath = fullfile(savebasepath, 'maxOverlap.mat');
    save(savepath, 'maxOverlap');

  end % parameter set s
    
end