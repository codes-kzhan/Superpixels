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
% main_evaluateBSDS_affine(alg_paramfilename, bsds_affine_paramfilename, colors, lineStyles, markerStyles)
%
% % Creates and shows evaluation of the results of a prior run of
% the benchmark metric. 
%
% alg_paramfilename ... algorithm parameter filename
% bsds_affine_paramfilename ... dataset parameter filename
% colors ... colors of the plots
% lineStyles ... line styles of the plots
% markerStyles ... marker styles of the plots
%
function main_evaluateBSDS_affine(alg_paramfilename, bsds_affine_paramfilename, colors, lineStyles, markerStyles)

    if ~iscell(alg_paramfilename)
        alg_paramfilename = {alg_paramfilename};
        n=1;
    else
        n = numel(alg_paramfilename);
    end

   
    if ~exist('colors', 'var')
        for i=1:n
            colors(i,:) = [1; 0; 0];
        end
    end
    
    if ~exist('lineStyles', 'var')
        for i=1:n
            lineStyles{i} = '-';
        end
    end
    
    if ~exist('markerStyles', 'var')
      for i=1:n
          markerStyles{i} = 'o';
      end
    end
    % for each BPF
    for idx = 1:n
        if isempty(alg_paramfilename{idx})
            continue;
        end
        
        % load benchmark parameter files BPF, APF
        params = ReadYaml(alg_paramfilename{idx});
        bsds_affine_params = ReadYaml(bsds_affine_paramfilename);
        
        % for each parameterset 
        for s=1:numel(params.segParams.set)
      
            % skip if this is not the oneShotSet indicated by oneShotSetName
            if ~strcmp(params.segParams.set{s}.name, params.segParams.oneShotSetName)
              continue;
            end

            % load results for affine set (get precision and recall vectors)
            loadPathBase =  fullfile( params.segSaveDir, ...
                                  bsds_affine_params.id, ...
                                  params.id, ...
                                  params.segParams.set{s}.name); 
            loadPath = fullfile(loadPathBase, 'benchmarkAffineResults.mat');
            if ~exist(loadPath, 'file')
              h(idx) = plot(0,1);
              names{idx} = [params.id ' --FAILED--'];
              continue;
            end
            R = load(loadPath, 'R');  

            % compute average F for each affine set
            for i=1:numel(R.R)
                F_vec = 2*R.R{i}.precision.*R.R{i}.recall ./ (R.R{i}.precision + R.R{i}.recall);
                F(i) = mean(F_vec);  
                parVal(i) = bsds_affine_params.affine_trafo{i}.parVal;
            end
            
            % plot
            if exist('fig', 'var'), fig = figure(fig); else fig = figure(); end
            hold on;
            set(gcf, 'color', [1 1 1]);
            set(gca,'FontSize',14)
            grid on;
            
            h(idx) = plot(parVal, F, 'color', colors(idx, :), 'lineStyle', lineStyles{idx}, 'marker', markerStyles{idx});
            names{idx} = params.id;
            xlabel(bsds_affine_params.xLabel);
            ylabel('F');
            
%             % rotation
%             if strcmp(filenameAPF, 'apf/apf_rotation.txt')
%                 if exist('f_r', 'var'), f_r = figure(f_r); else f_r = figure(); end
%                 hold on;
%                 set(gca,'FontSize',14)
%                 grid on;
%                 plot([0 5 10 15 30 45 60 75 90 105 120 135 150 165 180] , [1 F], 'color', colors(idx, :), 'lineStyle', lineStyles{idx}, 'marker', '+');
%                 xlabel('Rotation angle in degree');
%                 ylabel('F');
%             end
% 
%             % translation
%             if strcmp(filenameAPF, 'apf/apf_translation.txt')
%                 if exist('f_t', 'var'), f_t = figure(f_t); else f_t = figure(); end
%                 hold on;
%                 set(gca,'FontSize',14)
%                 grid on;
%                 plot([1 5 10 20 25 30 40 50 60 70 80 90 100] , F,  'color', colors(idx, :), 'lineStyle', lineStyles{idx}, 'marker', '+');
%                 xlabel('Horizontal and Vertical Shift in Pixel');
%                 ylabel('F');
%             end
% 
%             % sacle
%             if strcmp(filenameAPF, 'apf/apf_scale.txt')
%                 if exist('f_s', 'var'), f_s = figure(f_s); else f_s = figure(); end
%                 F = [F(1:3), 1, F(4:6)];
%                 semilogx([0.25 0.5 0.6666 1 1.5 2 4] , F,  'color', colors(idx, :), 'lineStyle', lineStyles{idx}, 'marker', '+');
%                 hold on;
%                 set(gca,'FontSize',14)
%                 set(gca,'XTick',[0.25 0.5 0.6666 1 1.5 2 4])
%                 set(gca,'XTickLabel',{'0.25', '0.5', '0.66', '1', '1.5',  '2',  '4'})
%                 xlabel('Scale Factor');
%                 ylabel('F');
%                 grid on;
%             end
% 
%             % shear
%             if strcmp(filenameAPF, 'apf/apf_shear.txt')
%                 if exist('f_ss', 'var'), f_ss = figure(f_ss); else f_ss = figure(); end
%                 plot([0 0.01 0.025 0.05 0.1 0.25 0.5] , [1 F],  'color', colors(idx, :), 'lineStyle', lineStyles{idx}, 'marker', '+');
%                 hold on;
%                 set(gca,'FontSize',14)
%                 xlabel('Horizontal and Vertical Shear Factor');
%                 ylabel('F');
%                 grid on;
%             end
        end
                
%         legend(h, names);
    end
    
    
    
end