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
% main_evaluateSintelBenchmarkMUSE(parameterfiles, ...
%                                sintel_paramfilename, ...
%                                colors, ...
%                                lineStyles, ...
%                                markerStyles, ...
%                                legendFlag)
%
% Creates and shows evaluation of the results of a prior run of
% the benchmark metric. 
%
% parameterfiles ... cell array of algorithm parameter filename
% sintel_paramfilename ... dataset parameter filename
% colors ... colors of the plots
% lineStyles ... line styles of the plots
% markerStyles ... marker styles of the plots
% legendFlag .. toggle legend
%
function main_evaluateSintelBenchmarkMUSE(parameterfiles, ...
                                          sintel_paramfilename, ...
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

    sintel_params = ReadYaml(sintel_paramfilename);
    
    % load results of each parameterfile
    for idx = 1:numel(parameterfiles)
        paramfilename = parameterfiles{idx};

        % parse parameter file
        params = ReadYaml(paramfilename);

        % prepare loading result storage
        savebasepath = fullfile(params.segSaveDir, ...
                                sintel_params.id, ...
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
              
            load(savepath) ; % 'undersegError_vec', 'nSegments_vec'
              
            nanIdx = isnan(undersegError_vec);
            nSegments_vec(nanIdx) = [];
            undersegError_vec(nanIdx) = [];
            
            fprintf('flowD=%d --> mean error: %d\n', flowD, mean(undersegError_vec));
            
            % collect results
            R(idx).mean_nSegments_vec = [R(idx).mean_nSegments_vec mean(nSegments_vec)];
            R(idx).mean_undersegError_vec = [R(idx).mean_undersegError_vec mean(undersegError_vec)];
           
           
        end % parameter set s
        
    end
    
    
    % create plot
    figure();
    hold on;
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
    if legendFlag, legend(h,t, 'location', 'southeast'); end %,'location', 'EastOutside'); 
    grid on;
    axis([0 2000 0 0.9])
    set(gcf,'Color',[1 1 1]);
    fontsize=16;
    set(gca,'fontsize',fontsize)
    set(gcf,'color',[1 1 1])
    xlabel('# Segments','fontsize',fontsize);
    ylabel('Motion Undersegmentation Error (MUSE)','fontsize',fontsize);
    title('a) Sintel','fontsize',fontsize)
    
%     export_fig('-r300', 'results/figures/underseg_error.pdf');
    
%     figure();
%     hold on;
%     xlabel('# Segments');
%     ylabel('Undersegmentation error');
%     [C L] = getHighContrastColormap;    
%     for idx=1:numel(R)
%         h(idx) = plot(R(idx).mean_nSegments_vec, R(idx).mean_undersegError_vec, 'color', C(idx,:), 'LineStyle', L{idx});
%         t{idx} = R(idx).name;        
%     end
%     legend(h,t);
%     grid on;
%     axis([0 2000 0 0.8])
%     set(gcf,'Color',[1 1 1]);
%     export_fig('-r300', 'results/figures/underseg_error.pdf');

end