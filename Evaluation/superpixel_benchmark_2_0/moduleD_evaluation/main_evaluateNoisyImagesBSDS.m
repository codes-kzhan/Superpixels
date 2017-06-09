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
% main_evaluateNoisyImagesBSDS(alg_paramfilename, 
%                              bsds_noise_paramfilename, 
%                              colors, 
%                              lineStyles, 
%                              markerStyles, 
%                              plotF_flag, 
%                              plotOv_flag, 
%                              legend_flag, 
%                              name)
%
% Creates and shows evaluation of the results of a prior run of
% the benchmark metric. 
%
% alg_paramfilename ... cell array of algorithm parameter filename
% bsds_noise_paramfilename ... dataset parameter filename
% colors ... colors of the plots
% lineStyles ... line styles of the plots
% markerStyles ... marker styles of the plots
% legendFlag ... toggle legend
% name ... title of the plot
% plotF_flag ... toggle F-Score plot
% plotOv_flag ... toggle Overlap plot
%
function main_evaluateNoisyImagesBSDS(alg_paramfilename, bsds_noise_paramfilename, colors, lineStyles, markerStyles, plotF_flag, plotOv_flag, legend_flag, name)

  if ~exist('colors', 'var'), [colors, ~, ~] = getHighContrastColormap(); end
  if ~exist('lineStyles', 'var'), [~,lineStyles, ~] = getHighContrastColormap(); end
  if ~exist('markerStyles', 'var'), [~, ~, markerStyles] = getHighContrastColormap(); end
  if ~exist('plotF_flag', 'var'), plotF_flag=1; end
  if ~exist('plotOv_flag', 'var'), plotOv_flag=1; end
  if ~exist('legend_flag', 'var'), legend_flag=1; end
  fonstsize = 16;

  fprintf('main_evaluateBenchmarkNoisyImagesBSDS: %s\n', bsds_noise_paramfilename);

  %% load benchmark parameter files 
  noiseParams = ReadYaml(bsds_noise_paramfilename);
  
  % prepare F plot
  if plotF_flag
    figF = figure();
    
    hold on;  
    set(gca, 'fontsize', fonstsize);
    ylabel('F');
    xlabel(noiseParams.xLabel);
    set(gca, 'ylim', [0 1]);
    if ~exist('name', 'var')
      title(noiseParams.id, 'interpreter', 'none');
    else
      title(name, 'interpreter', 'none');
    end
    set(gcf, 'color', [1 1 1]);
  end
  
  if plotOv_flag
    figO = figure();
    hold on;
    set(gca, 'fontsize', fonstsize);
    ylabel('Mean Maximum Possible Overlap');
    xlabel(noiseParams.xLabel);
    set(gca, 'ylim', [0 1]);
    if ~exist('name', 'var')
      title(noiseParams.id, 'interpreter', 'none');
    else
      title(name, 'interpreter', 'none');
    end
    set(gcf, 'color', [1 1 1]);
  end

  
  for idx = 1:numel(alg_paramfilename)
    params = ReadYaml(alg_paramfilename{idx});

    %% process each noise parameterset 
    % initialize with values for unchanged images
    F_vec = 1;
    meanMaxOverlap_vec = 1;
    X_vec = 0;
    failedFlag=0;
    for nIdx=1:numel(noiseParams.noiseSet)
        noisyPathBase = fullfile( noiseParams.noiseImageSaveDir, ...  % results
                                  noiseParams.id, ...                 % saltAndPepper
                                  params.id, ...                      % watershed
                                  noiseParams.noiseSet{nIdx}.name);   % d005

        % load results
        loadPath = fullfile(noisyPathBase, 'results.mat');
        if ~exist(loadPath, 'file')
          failedFlag=1;
          break;
        end
        load(loadPath, 'recall', 'precision', 'meanMaxOverlap');

        F_vec(end+1) = mean(2*precision.*recall ./ (precision+recall));
        meanMaxOverlap_vec(end+1) = mean(meanMaxOverlap);
        X_vec(end+1) = noiseParams.noiseSet{nIdx}.parVal;
    end

    if failedFlag
      if plotF_flag
        figure(figF);
        hF(idx) = plot(0,1);
      end
      
      if plotOv_flag
        figure(figO);
        hO(idx) = plot(0,1);
      end
      
      names{idx} = [params.id '--FAILED--'];
    else
      if plotF_flag
        figure(figF);
        hF(idx) = plot(X_vec, F_vec, ...
                       'color', colors(idx,:), ...
                       'LineStyle', lineStyles{idx}, ...
                       'Marker', markerStyles{idx});
      end
      
      if plotOv_flag
        figure(figO);
        hO(idx) = plot(X_vec, meanMaxOverlap_vec, ...
                       'color', colors(idx,:), ...
                       'LineStyle', lineStyles{idx}, ...
                       'Marker', markerStyles{idx});
      end
      names{idx} = params.id;
    end
    
  end
  
  if plotF_flag && legend_flag
    figure(figF);
    legend(hF, names);
  end

  if plotOv_flag && legend_flag
    figure(figO);
    legend(hO, names);
  end
end

