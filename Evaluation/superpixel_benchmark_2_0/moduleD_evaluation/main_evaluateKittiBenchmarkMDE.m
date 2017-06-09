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
% main_evaluateKittiBenchmarkMDE(parameterfiles, ...
%                                kitti_paramfilename, ...
%                                errorbar_flag, ...
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
% errorbar_flag  ... triggers drawing or error bars [default: 0]
%
function main_evaluateKittiBenchmarkMDE(parameterfiles, ...
                                        kitti_paramfilename, ...
                                        errorbar_flag, ...
                                        colors, ...
                                        lineStyles, ...
                                        markerStyles, ...
                                        legendFlag)

    if ~exist('errorbar_flag', 'var'), errorbar_flag=0; end
    if ~exist('colors', 'var'), [colors, ~, ~] = getHighContrastColormap(); end
    if ~exist('lineStyles', 'var'), [~,lineStyles, ~] = getHighContrastColormap(); end
    if ~exist('markerStyles', 'var'), [~, ~, markerStyles] = getHighContrastColormap(); end 
    if ~exist('legendFlag', 'var'), legendFlag = 1; end
    
    % set paths
    set_paths;

    if ~iscell(parameterfiles)
      tmp{1} = parameterfiles; 
      parameterfiles = tmp;
    end

    if numel(parameterfiles)==1
      flowD_vec = [1];              
      R = loadEvaluationResultsKitti(parameterfiles{1}, kitti_paramfilename, flowD_vec);
    else      
      flowD_vec = [1];
      for i=1:numel(parameterfiles)
        Q = loadEvaluationResultsKitti(parameterfiles{i}, kitti_paramfilename, flowD_vec);
        R(i) = Q(1);
      end  
    end
        
    % create plot
    figure();
    hold on;
    grid on;
    for idx=1:numel(R)
%         h(idx) = plot(     R(idx).mean_nBoundaryPixels_vec, R(idx).mean_weightedFlowGradientError_vec, 'color', C(idx,:), 'LineStyle', L{idx});
        if ~R(idx).failedFlag
          h(idx) = plot(R(idx).mean_nSegments_vec, ...
                        R(idx).mean_weightedFlowGradientErrorRatio_vec, ...
                        'color', colors(idx,:), ...
                        'LineStyle', lineStyles{idx}, ...
                        'Marker', markerStyles{idx});
          if errorbar_flag
            errorbar(   R(idx).mean_nSegments_vec, ...
                        R(idx).mean_weightedFlowGradientError_vec, ...
                        min(R(idx).std_weightedFlowGradientError_vec, R(idx).mean_weightedFlowGradientError_vec), ...
                        R(idx).std_weightedFlowGradientError_vec, ...
                        'color', colors(idx,:), 'lineStyle', ':');
          end
          t{idx} = [R(idx).name '{     }'];   
        else
          h(idx) = plot(0,1);           
          t{idx} = [R(idx).name '--FAILED-- {     }'];   
        end
        
    end
    
    if  legendFlag
      if exist('names', 'var'), legend(h,names); else legend(h,t); end
    end
    axis([0 2000 0 25]);
    set(gcf,'Color',[1 1 1]);
    fontsize=16;
    set(gca,'fontsize',fontsize)
    set(gca,'fontsize',fontsize)
    xlabel('# Segments','fontsize',fontsize);
    ylabel('Motion Discontinuity Error (MDE)','fontsize',fontsize);
    title('b) KITTI','fontsize',fontsize)
%     export_fig('-r300', 'results/figures/motionGradient_error_kitti.pdf');
    
end

function R = loadEvaluationResultsKitti(paramfilename, kitti_paramfilename, flowD_vec)
    
    if ~exist('type', 'var'), type = 'std'; end

    % parse parameter file
    params = ReadYaml(paramfilename);
    kitti_params = ReadYaml(kitti_paramfilename);

    % get KITTI image paths 
    kitti = getKittiImage(kitti_params.kittiPath, kitti_params.nImagePairs);    
                        
    % prepare result storage
    savebasepath = fullfile(params.segSaveDir, ...
                            kitti_params.id, ...
                            params.id, ...
                            'benchmark_results');
                    
    
    fprintf('\n====== %s =======\n', paramfilename);
    % for each evaluation scheme
    idx=1;
    R(idx).failedFlag = 0;
    for flowD = flowD_vec
        fprintf('... flowD %d\n', flowD);
        
        R(idx).name = params.id;
        R(idx).flowD = flowD;
        R(idx).mean_nSegments_vec = [];
        R(idx).mean_weightedFlowGradientError_vec = [];
        R(idx).mean_weightedFlowGradientErrorRatio_vec = [];
        R(idx).mean_nBoundaryPixels_vec = [];
        R(idx).std_nSegments_vec = [];
        R(idx).std_weightedFlowGradientError_vec = [];
        R(idx).std_weightedFlowGradientErrorRatio_vec = [];
        R(idx).std_nBoundaryPixels_vec = [];
        
        
        % for each parameter set
        for s=1:numel(params.segParams.set)
        
            % collect error measures
            savepath = fullfile(savebasepath, sprintf('weightedFlowGradientError-%s-d1.mat', params.segParams.set{s}.name));

            if ~exist(savepath,'file')
              R(idx).failedFlag = 1;
              break;
            end
            
            load(savepath) ; % weightedFlowGradientError_vec, nSegments_vec, sumFlowGradients_vec, nBoundaryPixels_vec              
            nanIdx = isnan(weightedFlowGradientError_vec);
            weightedFlowGradientError_vec(nanIdx) = [];
            nSegments_vec(nanIdx) = [];
            sumFlowGradients_vec(nanIdx) = [];
            nBoundaryPixels_vec(nanIdx) = [];
            
            infIdx = isinf(weightedFlowGradientError_vec);
            weightedFlowGradientError_vec(infIdx) = [];
            nSegments_vec(infIdx) = [];
            sumFlowGradients_vec(infIdx) = [];
            nBoundaryPixels_vec(infIdx) = [];
            
            weightedFlowGradientErrorRatio_vec = weightedFlowGradientError_vec ./ sumFlowGradients_vec;
            
            fprintf('   paramset:=%s --> mean error: %d\n', params.segParams.set{s}.name, mean(weightedFlowGradientError_vec));
            
            % collect results 
            R(idx).mean_nSegments_vec                      = [R(idx).mean_nSegments_vec                      mean(nSegments_vec)];
            R(idx).mean_weightedFlowGradientError_vec      = [R(idx).mean_weightedFlowGradientError_vec      mean(weightedFlowGradientError_vec)];
            R(idx).mean_weightedFlowGradientErrorRatio_vec = [R(idx).mean_weightedFlowGradientErrorRatio_vec mean(weightedFlowGradientErrorRatio_vec)];
            R(idx).mean_nBoundaryPixels_vec                = [R(idx).mean_nBoundaryPixels_vec                mean(nBoundaryPixels_vec)];
                 
            R(idx).std_nSegments_vec                      = [R(idx).std_nSegments_vec                      std(double(nSegments_vec))];
            R(idx).std_weightedFlowGradientError_vec      = [R(idx).std_weightedFlowGradientError_vec      std(weightedFlowGradientError_vec)];
            R(idx).std_weightedFlowGradientErrorRatio_vec = [R(idx).std_weightedFlowGradientErrorRatio_vec std(weightedFlowGradientErrorRatio_vec)];
            R(idx).std_nBoundaryPixels_vec                = [R(idx).std_nBoundaryPixels_vec                std(nBoundaryPixels_vec)];
        end % parameter set s
        idx = idx+1;
        
    end % flowD
    

    
end