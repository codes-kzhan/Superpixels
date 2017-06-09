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
% main_evaluateCompactness(filename, bsds_paramfilename, varargin)
%
% Creates and shows evaluation of the results of a prior run of
% the benchmark metric. 
%
% alg_paramfilename ... cell array of algorithm parameter filenames
% bsds_paramfilename ... dataset parameter filename 
% 'lineStyle' ... line style of the curve
% 'markerStyles' ... marker style of the plot
% 'colors' ... colors of the plots
% 'PR_scheme' ... 'line', 'points', 'contours', 'areas'
% 'names' ... names for the legend (cell array of string included in the plots (e.g. names of the
%             algorithms))
% 'legendFlag' ... toggle legend, default 1
% 'diameterFlag' ... use isodiametric measure
% 'smooth' ... size of the smoothing, default 0 (=no smoothing)
%
function main_evaluateCompactness(filename, bsds_paramfilename, varargin)

  % parse input
  ip = inputParser;
  ip.addOptional('PR_scheme', 'line');
  ip.addOptional('names', []);
  ip.addOptional('colors', nan);
  ip.addOptional('lineStyles', nan);
  ip.addOptional('markerStyles', nan);
  ip.addOptional('diameterFlag', 0);
  ip.addOptional('legendFlag', 1);
  ip.addOptional('smooth', 0);
  ip.parse(varargin{:});

  % colors
  if ~isnan(ip.Results.colors)    
    colors = ip.Results.colors;
  else
    [colors] = getHighContrastColormap;
  end

  % lineStyle
  if iscell(ip.Results.lineStyles)
    lineStyles = ip.Results.lineStyles;    
  else
    [~, lineStyles] = getHighContrastColormap;
  end
  
  % markerStyles
  if iscell(ip.Results.markerStyles)    
    markerStyles = ip.Results.markerStyles;
  else
    [~, ~, markerStyles] = getHighContrastColormap;
  end
  
  % prepare plot
  cFig = figure();
  if ip.Results.diameterFlag          
    yAxisText = 'Compactness from Isodiametric Quotient';
  else
    yAxisText = 'Compactness from Isoperimetric Quotient';
  end
  prepareCompactnessPlot(yAxisText);

  bsds_params = ReadYaml(bsds_paramfilename);

  % show files

  % prepare plot handles
  cHandles = [];
  names = {};
  for i=1:length(filename)
      params = ReadYaml(filename{i});

      % load results
      cVec = [];
      nVec = [];   
      failedFlag=0;               
      for s=1:numel(params.segParams.set)  
        loadPathBase =  fullfile(params.segSaveDir, bsds_params.id, params.id, params.segParams.set{s}.name);             
        
        % use diameter or boundary length based evaluation
        if ip.Results.diameterFlag
          loadPath =  fullfile(loadPathBase, 'benchmarkResultCompactnessDiameter.mat');  
        else
          if ip.Results.smooth == 0            
            loadPath =  fullfile(loadPathBase, 'benchmarkResultCompactness_s0.mat');   
          elseif ip.Results.smooth == 5            
            loadPath =  fullfile(loadPathBase, 'benchmarkResultCompactness_s5.mat');   
          else
            fprintf('Warning: Unknown smooth %d\n', ip.Result.smooth);          
%           loadPath =  fullfile(loadPathBase, 'benchmarkResultCompactness_s3.mat'); 
          end
        end
                
        if ~exist(loadPath, 'file')
          failedFlag = 1;
          break;
        end    
        
        load(loadPath, 'compactness', 'imNSegments');

        if s==11
        end

        nn = 200;
        if 1 %mean(imNSegments(1:5))>=20
          cVec(end+1) = mean(compactness(1:nn));
          nVec(end+1) = mean(imNSegments(1:nn));
          fprintf('%s: c=%d, n=%d\n', filename{i}, mean(compactness(1:nn)), mean(imNSegments(1:nn)));
        end
      end

      % plot 
      if ~failedFlag
        cHandles(end+1) = plot(nVec, cVec, ...
                              'color', colors(i,:),...
                              'LineStyle', lineStyles{i}, ...
                              'Marker', markerStyles{i});
        names{end+1} = params.id;
      else
        cHandles(end+1) = plot(0,0.9);
        names{end+1} = [params.id ' --FAILED--'];
      end
        
  end

  % legend
  figure(cFig); 
  if ip.Results.legendFlag
    legend( cHandles, names, 'location', 'eastoutside');
  end

    
end

function prepareCompactnessPlot(yAxisText)
  
    hold on;
    set(gca,'FontSize',14)
    set(gcf,'color',[1 1 1]);
    xlabel('Number of Segments');
    ylabel(yAxisText);
%     grid on;
    axis( [0 2500 0 1]);
end
