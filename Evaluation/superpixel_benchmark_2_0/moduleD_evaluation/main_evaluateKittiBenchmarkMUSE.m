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
% main_evaluateKittiBenchmarkMUSE(parameterfiles, ...
%                                kitti_paramfilename, ...
%                                colors, ...
%                                lineStyles, ...
%                                markerStyles, ...
%                                legendFlag)
%
% Creates and shows evaluation of the results of a prior run of
% the benchmark metric. 
%
% parameterfiles ... cell array of algorithm parameter filename
% kitti_paramfilename ... dataset parameter filename
% colors ... colors of the plots
% lineStyles ... line styles of the plots
% markerStyles ... marker styles of the plots
% legendFlag .. toggle legend
%
function main_evaluateKittiBenchmarkMUSE(parameterfiles,...
                                         kitti_paramfilename, ...
                                         colors, ...
                                         lineStyles, ...
                                         markerStyles, ...
                                         legendFlag)

    if ~exist('colors', 'var'), [colors, ~, ~] = getHighContrastColormap(); end
    if ~exist('lineStyles', 'var'), [~,lineStyles, ~] = getHighContrastColormap(); end
    if ~exist('markerStyles', 'var'), [~, ~, markerStyles] = getHighContrastColormap(); end    
    if ~exist('legendFlag', 'var'), legendFlag = 1; end
    
                                       
    set_paths;    

    if ~iscell(parameterfiles)
      tmp{1} = parameterfiles; 
      parameterfiles = tmp;
    end
    
    flowD = 1;  
    
    for idx = 1:numel(parameterfiles)
        paramfilename = parameterfiles{idx};

        % parse parameter file
        params = ReadYaml(paramfilename);
        kitti_params = ReadYaml(kitti_paramfilename);


        % prepare result storage
        savebasepath = fullfile(params.segSaveDir, ...
                                kitti_params.id, ...
                                params.id, ...
                                'benchmark_results');



        R(idx).name = params.id;
        R(idx).mean_nSegments_vec = [];
        R(idx).mean_undersegError_vec = [];

        % for each parameter set
        for s=1:numel(params.segParams.set)
            fprintf('=== working on paramset: %s ===\n', params.segParams.set{s}.name);
            R(idx).failedFlag = 0;
            
            % collect error measures
            savepath = fullfile(savebasepath, sprintf('underseg-%s-d%d.mat', params.segParams.set{s}.name, flowD));
            if ~exist(savepath, 'file')
              R(idx).failedFlag = 1;
              break
            end
            
            load(savepath);  % 'undersegError_vec', 'nSegments_vec'

            R(idx).mean_nSegments_vec     = [ R(idx).mean_nSegments_vec     mean(nSegments_vec) ];
            R(idx).mean_undersegError_vec = [ R(idx).mean_undersegError_vec mean(undersegError_vec) ];

        end % parameter set s
    end
     
    % create plot
    figure();
    hold on;
    [C L P] = getHighContrastColormap;    
    for idx=1:numel(R)
      if ~R(idx).failedFlag
        h(idx) = plot(R(idx).mean_nSegments_vec, ...
                      R(idx).mean_undersegError_vec, ...
                      'color', colors(idx,:), ...
                      'LineStyle', lineStyles{idx}, ...
                      'Marker', markerStyles{idx});
        t{idx} = [R(idx).name '{     }'];        
      else
        h(idx) = plot(0,0.5);
        t{idx} = [R(idx).name ' --FAILED-- {     }'];        
      end     
    end
    if legendFlag, legend(h,t); end %,'location', 'EastOutside');
    grid on;
    axis([0 2000 0 0.9])
    set(gcf,'Color',[1 1 1]);
    fontsize=16;
    set(gca,'fontsize',fontsize)
    set(gca,'fontsize',fontsize)
    xlabel('# Segments','fontsize',fontsize);
    ylabel('Motion Undersegmentation Error (MUSE)','fontsize',fontsize);
    title('b) KITTI','fontsize',fontsize)
    
%     export_fig('-r300', 'results/figures/underseg_error_kitti.pdf');

end