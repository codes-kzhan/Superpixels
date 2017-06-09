% Superpixel Benchmark
% Copyright (C) 2012  Peer Neubert, peer.neubert@etit.tu-chemnitz.de
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
% evaluateBenchmark(filename, bsds_paramfilename, varargin)
%
% Creates and shows evaluation of the results of a prior run of
% runBenchmark. Evaluation includes boundary recall, undersegmentation
% erros and runtime.
%
% filename ... algorithm parameter filename
% bsds_paramfilename ... dataset parameter filename 
% 'PR_scheme' ... 'line', 'points', 'contours', 'areas'
% 'names' ... names for the legend (cell array of string included in the plots (e.g. names of the
%             algorithms))
% 'lineStyle' ... line style of the curve
% 'markerStyles' ... marker style of the plot
% 'colors' ... colors of the plots
%  'procRuntime' ... toggle runtime plot, default 1
%  'procUSE' ... toggle undersegementation error  plot, default 1
%  'procBR' ... toggle boundary recall plot, default 1
%  'legendFlag' ... toggle legend
%
function main_evaluateBSDS(filename, bsds_paramfilename, varargin)

   % parse input
  ip = inputParser;
  ip.addOptional('PR_scheme', 'line');
  ip.addOptional('names', []);
  ip.addOptional('procRuntime', 1);
  ip.addOptional('procUSE', 1);
  ip.addOptional('procBR', 1);
  ip.addOptional('colors', nan);
  ip.addOptional('lineStyles', nan);
  ip.addOptional('markerStyles', nan);
  ip.addOptional('legendFlag', 1);
  
  ip.parse(varargin{:});
  
  % colors
  if isnan(ip.Results.colors)    
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
    
  % legend
  if iscell(filename)
    names = {};
    for i=1:length(filename)      
      params = ReadYaml(filename{i});
      names{i} = params.id;
    end
        
    if isempty(ip.Results.names)
      namesLegend = names;
    else
      namesLegend = ip.Results.names;
    end
  end
  
  % recall-#Segments
  if ip.Results.procBR
    nrFig = figure(); 
    prepareBoundaryRecallPlot();

    % show files
    if iscell(filename)
      % prepare plot handles
      nrHandles = zeros(length(filename), 1);
      for i=1:length(filename)
          [~, nrHandles(i), failedFlag] = evalBSDS_plot(filename{i},bsds_paramfilename, ...
                                                        'figure', nrFig, ...
                                                        'metric', 'boundary_recall', ...
                                                        'color', colors(i,:), ...
                                                        'lineStyle', lineStyles{i}, ...
                                                        'markerStyle', markerStyles{i}, ...
                                                        'nameFlag', 0);
          if failedFlag
            namesLegend{i} = [namesLegend{i} ' --FAILED--'];
          end
      end

      if ip.Results.legendFlag
        figure(nrFig); legend( nrHandles, namesLegend, 'Location','SouthEast');
      end
    else
      % just plot
      evalBSDS_plot(filename,bsds_paramfilename,'figure', nrFig, 'metric', 'boundary_recall','nameFlag', 0);
    end
  end

        
  % undersegmentation error-#Segments
  if ip.Results.procUSE
    nuFig = figure(); 
    prepareUndersegmentationErrorPlot();

    % show files
    if iscell(filename)
      % prepare plot handles
      nuHandles = zeros(length(filename), 1);
      for i=1:length(filename)
        [~, nuHandles(i), failedFlag] = evalBSDS_plot(filename{i},bsds_paramfilename,...
                                                    'figure', nuFig, ...
                                                    'metric', 'undersegmentation', ...
                                                    'color', colors(i,:),  ...
                                                    'lineStyle', lineStyles{i},  ...
                                                     'markerStyle', markerStyles{i}, ...
                                                    'nameFlag', 0);
        if failedFlag
          namesLegend{i} = [namesLegend{i} ' --FAILED--'];
        end
      end
      if ip.Results.legendFlag
        figure(nuFig); legend( nuHandles, namesLegend);
      end
    else
      % just plot
      evalBSDS_plot(filename,bsds_paramfilename,'figure', nuFig, 'metric', 'undersegmentation', 'nameFlag', 0);
    end
  end
  
  % runtime-#Segments
  if ip.Results.procRuntime
    tFig = figure(); 
    prepareRuntimePlot(1);

    % show files
    if iscell(filename)
      % prepare plot handles
      tHandles = zeros(length(filename), 1);
      for i=1:length(filename)
        [~, tHandles(i), failedFlag] = evalBSDS_plot(filename{i},bsds_paramfilename, ...
                                                     'figure', tFig,  ...
                                                     'metric', 'runtime', ... 
                                                     'color', colors(i,:),  ...
                                                     'lineStyle', lineStyles{i},  ...
                                                     'markerStyle', markerStyles{i}, ...
                                                     'nameFlag', 0);
        if failedFlag
          namesLegend{i} = [namesLegend{i} ' --FAILED--'];
        end                                       
      end
      if ip.Results.legendFlag
        if ip.Results.legendFlag==2 % pSLIC runtime
          figure(tFig); legend( tHandles, namesLegend, 'Location','east' ) ; %,'Orientation','horizontal');
        else          
          figure(tFig); legend( tHandles, namesLegend);
        end
      end
    else
      % just plot
      evalBSDS_plot(filename,bsds_paramfilename,'figure', tFig, 'metric', 'runtime', 'nameFlag', 0);
    end
  end
   
        
end


