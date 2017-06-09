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
% [fig_handle, plot_handle, failedFlag] = evalBPF_plot(alg_paramfilename, bsds_paramfilename, varargin)
% 
% Plot benchmark results (boundary recall, undersegmentation error or
% runtime) of a BPF. Called after runAlgorithm and runBenchmark. See
% evaluateBenchmark.m for example usage.
%
% alg_paramfilename ... algorithm parameter filename
% bsds_paramfilename ... dataset parameter filename 
% 'lineStyle' ... line style of the curve
% 'color' ... color of the plots
% 'figure' ... handle of the figure to draw on (otherwise a new figure is
%              created)
% 'metric' ... 'boundary_recall'
%              'undersegmentation'
%              'runtime'
% 'nameFlag' ... if true, the names from the BPF file are shown 
%
% failedFlag ... is set if any of the parametersets could not be loaded
%
function [fig_handle, plot_handle, failedFlag] = evalBSDS_plot(alg_paramfilename, bsds_paramfilename, varargin)
   
    % parse input
    ip = inputParser;
    ip.addOptional('figure', []);
    ip.addOptional('color', 'k');
    ip.addOptional('lineStyle', '-');
    ip.addOptional('markerStyle', 'o');
    ip.addOptional('metric', 'boundary_recall');
    ip.addOptional('nameFlag', 0);
    ip.parse(varargin{:});

    failedFlag=0;
    
    % prepare figure or use existing figure given by parameter
    if isempty(ip.Results.figure)
        fig_handle = figure();
        hold on;
        grid on;
    else
        fig_handle = figure(ip.Results.figure);
    end
    
    % parse parameter file
    params = ReadYaml(alg_paramfilename);
    bsds_params = ReadYaml(bsds_paramfilename);
    
    % build parameterSetNames by using all parameter set names from
    % benchmark parameter file 
    parameterSetNames = cell(length(params.segParams.set),1);
    for s=1:numel(params.segParams.set)
        parameterSetNames{s} = params.segParams.set{s}.name;
    end
       
    % for each entry in parameterSetNames: load results from disk and
    % collect data
    E = [];
    for s=1:numel(params.segParams.set)
        % load from disk
        loadPathBase =  fullfile(params.segSaveDir, bsds_params.id, params.id, params.segParams.set{s}.name);             
        loadPath =  fullfile(loadPathBase, 'benchmarkResult.mat'); 
        if ~exist(loadPath,'file')
          E(s).y = 0;
          E(s).x = 0;
          failedFlag=1;
          continue;
        end
        benchmarkResult = load(loadPath);
        
        % number of segments
        E(s).x = mean(benchmarkResult.imNSegments);
        
        if strcmp(ip.Results.metric, 'boundary_recall')
            % store average recall for later plotting of curve          
            E(s).y = mean(benchmarkResult.imRecall); 
        elseif strcmp(ip.Results.metric, 'undersegmentation')
            % store average undersegmentation error for later plotting of curve
            E(s).y = mean(benchmarkResult.imUnderseg); 
        elseif  strcmp(ip.Results.metric, 'runtime')
            % store average runtime and nSegments for later plotting of curve
            E(s).y = mean(benchmarkResult.imRuntime); 
        end
    end
    
    % plot curve
    yVec = cell2mat({E(:).y});
    xVec = cell2mat({E(:).x});
    plot_handle = plot(xVec, yVec, 'color', ip.Results.color, 'marker', ip.Results.markerStyle, 'LineStyle', ip.Results.lineStyle); 
%     plot_handle = plot(xVec, yVec, 'color', ip.Results.color, 'LineStyle', ip.Results.lineStyle);
    
    % show names
    if ip.Results.nameFlag
        if ~isempty(ip.Results.namesColor)
            for i=1:length(E)
                text(E(i).x,E(i).y,['  ' parameterSetNames{i}],...
                    'Clipping', 'on', ...
                    'Interpreter', 'non', ...
                    'color', ip.Results.namesColor);
            end
        else
             for i=1:length(E)
                text(E(i).x,E(i).y,['  ' parameterSetNames{i}],...
                    'Clipping', 'on', ...
                    'Interpreter', 'non', ...
                    'color', colors(i,:));
             end
        end
    end
    
end