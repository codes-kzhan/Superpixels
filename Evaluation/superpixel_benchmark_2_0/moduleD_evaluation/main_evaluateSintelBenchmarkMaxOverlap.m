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
% main_evaluateSintelBenchmarkMaxOverlap(alg_paramfilename, sintel_paramfilename)
%
% Creates and shows evaluation of the results of a prior run of
% the benchmark metric. 
%
% alg_paramfilename ... algorithm parameter filename
% sintel_paramfilename ... dataset parameter filename
%
function main_evaluateSintelBenchmarkMaxOverlap(alg_paramfilename_cell, sintel_paramfilename)

  
  % parse parameter file
  sintel_params = ReadYaml(sintel_paramfilename);

  % get Sintel image paths to 
  sintel = getSintelImage(sintel_params.sintelPath,...  
                          'nScenes', sintel_params.nSintelScenes, ...
                          'nImagesPerScene', sintel_params.nImagesPerScene, ...
                          'renderType', sintel_params.renderType);

  % prepare plot
  figure();
  grid on;
  hold on;           
         
  
  % collect data  
  for i=1:numel(alg_paramfilename_cell)
    alg_paramfilename = alg_paramfilename_cell{i};
    
     % parse parameter file
    params = ReadYaml(alg_paramfilename);

    % prepare result storage
    loadbasepath = fullfile(params.segSaveDir, ...
                            sintel_params.id, ...
                            params.id, ...
                            'benchmark_results');

     % for each parameter set
    for s=1:numel(params.segParams.set)

      % skip if this is not the oneShotSet indicated by oneShotSetName
      if ~strcmp(params.segParams.set{s}.name, params.segParams.oneShotSetName)
        continue;
      end
      
      % load results
      loadpath = fullfile(loadbasepath, 'maxOverlap.mat');
      if ~exist(loadpath, 'file')
        data(i).X = [params.id ('-F-')];
        data(i).Y = 0.5;
        sortCrit(i) = 1;
        continue;
      end
        
      load(loadpath, 'maxOverlap');
      
      % collect
      for j=1:numel(maxOverlap)
        data(i).X = repmat({params.id}, size(maxOverlap));
        data(i).Y = maxOverlap;
        sortCrit(i) = median(maxOverlap);
      end
    end                          
  end
  
  % combine by sortCrit
  [~, idx] = sort(sortCrit);
  X = {};
  Y = [];       
  for i=1:numel(idx)
    X = [X data(idx(i)).X];
    Y = [Y data(idx(i)).Y];
  end
    
  
  set(gca,'FontSize',14)
  set(gcf,'color',[1 1 1]);
  ylabel('Maximum Overlap');
  
  % plot
  boxplot(Y, X);
  set(gca, 'YLim', [0 1]);
  
  
end
