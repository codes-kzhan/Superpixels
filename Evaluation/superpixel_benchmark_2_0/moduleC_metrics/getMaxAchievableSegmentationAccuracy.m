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
% Compute getAchievableSegmentationAccuracy from a label image and a ground
% truth segmentation GT
%
function masa = getMaxAchievableSegmentationAccuracy(S, GT)
  
  % check image sizes
  [hS wS cS] = size(S);
  [hGT wGT cGT] = size(GT);
  if hS~=hGT || wS~= wGT || cS~=1 || cGT~=1
      fprintf('Size error in getAchievableSegmentationAccuracy\n');
      return;
  end

  % segment index should start with 1
  if min(S(:)) == 0
      S=S+1;
  end
  
  % Find label for each superpixel. The label is the label of the ground
  % truth segment with the largest overlap

  % number of segments in S and GT
  nS = double(max(S(:)));
  nGT = double(max(GT(:)));    

  % prepare intersection matrix: M(i,j) = overlapping of GT==i and S==j
  % prepare areas of segments of S and GT
  if max(nS, nGT) > 5000
    % slow version
    areaS = zeros(nS,1);    
    areaGT = zeros(nGT,1);       
    M = zeros(nGT, nS);
    for y=1:hGT
        for x=1:wGT
            i = GT(y,x);
            j =  S(y,x);
            M(i, j) = M(i,j) + 1;
            areaGT(i) = areaGT(i)+1;
            areaS(j) = areaS(j)+1;
        end
    end    
  else        
    % vectorized version --> timing problems with large numbers of segments
    %                        (e.g. 10k)

    idx = ~isnan(GT) & ~isnan(S);
    n = sum(idx(:));
    vGT = double(GT(idx));
    vS = double(S(idx));

    maxVGT=max(vGT);
    maxVS=max(vS);

    areaGT = (hist(vGT, 1:maxVGT))';
    areaS = (hist(vS, 1:maxVS))';

    vSGT = vGT + (vS-1)*nGT;
    m = hist(vSGT, 1:(nGT*nS));
    M = reshape(m, [nGT nS]);       
  end

  % find best GT label for each superpixel
  [~, S_GT_labels] = max(M,[], 1);
    
  % Create label image SGT that holds for each pixel the
  % label of the assigned GT segment for the corresponding superpixel
  SGT = reshape(S_GT_labels(S), size(S));
  
  % compute segmentation accuracy
  masa = nnz(SGT==GT) / numel(GT);
  
  
end