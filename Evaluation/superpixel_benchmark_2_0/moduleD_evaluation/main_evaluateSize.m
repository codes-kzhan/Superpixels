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
% main_evaluateSize(filename, bsds_paramfilename, varargin)
%
% Creates and shows evaluation of the results of a prior run of
% the benchmark metric. 
%
% alg_paramfilename ... cell array of algorithm parameter filename
% bsds_paramfilename ... dataset parameter filename 
% 'lineStyle' ... line style of the curve
% 'color' ... color of the plots
% 'figure' ... handle of the figure to draw on (otherwise a new figure is
%              created)
% 'metric' ... 'boundary_recall'
%              'undersegmentation'
%              'runtime'
% 'PR_scheme' ... 'line', 'points', 'contours', 'areas'
% 'names' ... names for the legend (cell array of string included in the plots (e.g. names of the
%             algorithms))
%
function main_evaluateSize(filename, bsds_paramfilename, varargin)

  % parse input
  ip = inputParser;
  ip.addOptional('PR_scheme', 'line');
  ip.addOptional('names', []);
  ip.addOptional('colors', nan);
  ip.addOptional('lineStyles', nan);
  ip.addOptional('markerStyles', nan);
  ip.addOptional('legendFlag', 1);
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
  prepareSizePlot;

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
        loadPath =  fullfile(loadPathBase, 'benchmarkResultSegmentSizes.mat');  
                
        if ~exist(loadPath, 'file')
          failedFlag = 1;
          break;
        end    
        
        load(loadPath, 'segmentSizes', 'imNSegments');

        % compute std. dev for each image
        sizeStdDev = [];
        for j=1:numel(segmentSizes)
          sizeStdDev(end+1) = std(segmentSizes{j});
        end
        
        % get mean of all std devs
        cVec(end+1) = mean(sizeStdDev);
        nVec(end+1) = mean(imNSegments);
         
        
      end
      filename{i}
      cVec
      
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
    legend( cHandles, names, 'location', 'northeast');
  end

    
end

function prepareSizePlot(yAxisText)
  
    hold on;
    set(gca,'FontSize',14)
    set(gcf,'color',[1 1 1]);
    xlabel('Number of Segments');
    ylabel('Standard Deviation of Segment Size');
    axis( [0 2000 1 5000]);
end
