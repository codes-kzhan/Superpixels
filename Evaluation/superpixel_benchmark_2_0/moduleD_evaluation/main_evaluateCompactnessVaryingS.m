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
% main_evaluateCompactnessVaryingS(filename, bsds_paramfilename)
%
% Compare compactness measures for different smoothng sizes ss.
% e.g.: 
%  main_evaluateCompactnessVaryingS({'configs/algorithms/watershed.yaml','configs/algorithms/vl_slic.yaml'}, 'configs/bsds500.yaml');
%
function main_evaluateCompactnessVaryingS(filename, bsds_paramfilename)

  bsds_params = ReadYaml(bsds_paramfilename);
  
%   figure();
  clf
  hold on;
  
  c = distinguishable_colors(20);
  
  cHandles = [];
  names = {};
  for i=1:numel(filename)
    
    params = ReadYaml(filename{i});
    
    idx=0;
    for ss=[1, 3, 5, 7, 9, 11]
      idx=idx+1;
      
      color = c(idx,:);
      cVec = [];
      nVec = [];   
      for s=1:numel(params.segParams.set)  
        loadPathBase =  fullfile(params.segSaveDir, bsds_params.id, params.id, params.segParams.set{s}.name);             
        loadPath =  fullfile(loadPathBase, ['benchmarkResultCompactness_s' num2str(ss) '.mat']); 
        load(loadPath, 'compactness', 'imNSegments');

        cVec(end+1) = mean(compactness);
        nVec(end+1) = mean(imNSegments);
      end

      if i==1
        ls='-';
      else
        ls='-.';
      end
        
      cHandles(end+1) = plot(nVec, cVec, 'color', color, 'linestyle', ls);
      
      if strcmp(params.id, 'watershed')
        names{end+1} = ['WS' ' ' num2str(ss)];   
      else
        names{end+1} = [params.id ' ' num2str(ss)];      
      end
      
    end
  end

  legend( cHandles, names);
  
  % add black line at intersections of Slic and Watershed
  CO = [740 0.39; % blue
        325 0.43; % red
        208 0.456; % green
        167 0.49; % black
        118 0.525;  % yellow
        98 0.554]; % violett
  plot(CO(:,1), CO(:,2), 'ko-', 'linewidth', 3);
  
  hold on;
  set(gca,'FontSize',14)
  set(gcf,'color',[1 1 1]);
  xlabel('Number of Segments');
  ylabel('Compactness from Isoperimetric Quotient');
%     grid on;
  axis( [0 2000 0 0.8]);
  
  export_fig('-r300', fullfile('diss_figs/bsdsCompactness_peri_varyS.pdf'));
  
end
