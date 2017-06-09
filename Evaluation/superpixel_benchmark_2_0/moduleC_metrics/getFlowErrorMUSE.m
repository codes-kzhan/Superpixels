% Superpixel Benchmark
% Copyright (C) 2013  Peer Neubert, peer.neubert@etit.tu-chemnitz.de
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
% [undersegError visIm] = getFlowErrorMUSE(L1,L2, visFlag)
%
% Computes Motion UnderSegmentation Error (MUSE), an undersegmentation error
% measure of the compliance of two segmentations given by their label images.
% 
% The error measure is symmetric. This is obtained by averaging over both dirctions
% (comparing (L1, L2) and (L2,L1)).
% 
% The error (L1, L2) can be seen as error introduced when reconstructing L1 from
% segments of L2. When comparing (L1, L2) the function measures for each segment S1
% of L1 the error introduced by each segment S2 of L2 that overlapps with S1. For
% each of these pairs, the smaller number of the following two is included in the
% measure:
% - The part of S2 that is outside of S1 (the error introduced if we would use S2 to
%   reconstruct S1)
% - The overlap of S1 and S2 (the error introduced if we would reconstruct S1 without 
%   S2)
% 
% Input:
% L1, L2    ... label images
% visFlag   ... if set to 1 the segmentation error is visualized in the image
%               (slow!)
% 
% Output:
% muse   ... resulting motion undersegmentation error
% visIm           ... Shows boundaries of L1 in green, of L2 in red and common
%                     boundries in blue. The intensity of the segments
%                     corresponds to how often these pixels are counted in the
%                     undersegmentation error (black=0, white is 4)
%
function [muse visIm]= getFlowErrorMUSE(L1,L2, visFlag)

    if nargin<3
        visFlag=0;
    end
    visIm=[];
    
    % check image sizes
    [h1 w1 c1] = size(L1);
    [h2 w2 c2] = size(L2);
    if h1~=h2 || w1~= w2 || c1~=1 || c1~=1
        error('Size error in getFlowError_undersegmentation\n');
    end

    % segment index should start with 1
    if min(L1(:)) == 0
        L1=L1+1;
    end
    if min(L2(:)) == 0
        L2=L2+1;
    end
    
    % number of segments in S and GT
    n1 = double(max(L1(:)));
    n2 = double(max(L2(:)));    
    
    % if there are no valid pixels, we can not compute valid error
    % measurements
    if isnan(n1) || isnan(n2)
        muse = nan;        
        visIm = [];        
        return;
    end
    
    % GT = L1
    % prepare intersection matrix: M(i,j) = overlapping of L1==i and L2==j
    % prepare areas of segments of L2 and L1
    if 1
        % slow version
        area2 = zeros(n2,1);    
        area1 = zeros(n1,1);       
        M = zeros(n1, n2);
        n=0;
        for y=1:h1
            for x=1:w1
                i = L1(y,x);
                j = L2(y,x);
                if ~isnan(i) && ~isnan(j)
                    M(i, j) = M(i,j) + 1;
                    area1(i) = area1(i)+1;
                    area2(j) = area2(j)+1;
                    n=n+1;
                end
            end
        end
    else        
        % vectorized version --> problems with large numbers of segments
        %                        (e.g. 10k)
        
        idx = ~isnan(L1) & ~isnan(L2);
        n = sum(idx(:));
        v1 = L1(idx);
        v2 = L2(idx);

        maxV1=max(v1);
        maxV2=max(v2);
                
        area1 = (hist(v1, 1:maxV1))';
        area2 = (hist(v2, 1:maxV2))';

        v12 = v1 + (v2-1)*n1;
        m = hist(v12, 1:(n1*n2));
        M = reshape(m, [n1 n2]);       
        
    end
    

    if visFlag==0
        % no visualization
        
        sum_undersegError = 0;
        for i=1:n1
            idx = find(M(i,:));     % index of all non zero entries in this row
            for j=idx
                sum_undersegError = sum_undersegError + min(M(i,j), area2(j)-M(i,j));                            
            end        
        end    
        
        for j=1:n2
            idx = find(M(:,j))';     % index of all non zero entries in this column
            for i=idx
                sum_undersegError = sum_undersegError + min(M(i,j), area1(i)-M(i,j));                            
            end        
        end
        
        undersegError = sum_undersegError / (2*n);        
    else
        % visualize the errors
        
        visIm = zeros(size(L1));

        % proposed equation V2
        sum_undersegError = 0;
        for i=1:n1
            idx = find(M(i,:));     % index of all non zero entries in this row
            for j=idx
                sum_undersegError = sum_undersegError + min(M(i,j), area2(j)-M(i,j));            

                % visualize
                if M(i,j)<area2(j)-M(i,j)
                    k = find((L1==i) & (L2==j));
                    visIm(k) = visIm(k) + 1;
                else                
                    k = find((L1~=i) & (L2==j));
                    visIm(k) = visIm(k) + 1;
                end
            end        
        end    
        
        for j=1:n2
            idx = find(M(:,j))';     % index of all non zero entries in this column
            for i=idx
                sum_undersegError = sum_undersegError + min(M(i,j), area1(i)-M(i,j));     
                
                 % visualize
                if M(i,j)<area1(i)-M(i,j)
                    k = find((L1==i) & (L2==j));
                    visIm(k) = visIm(k) + 1;
                else                
                    k = find((L1~=i) & (L2==j));
                    visIm(k) = visIm(k) + 1;
                end
            end        
        end
        
        undersegError = sum_undersegError /(2*n);

        visIm( isnan(L1) | isnan(L2) ) = 0;

        L1_non_nan = nearestNeighborImageInterpolation(L1);
        
        B1 = multiLabelImage2boundaryImage(L1_non_nan);
        B2 = multiLabelImage2boundaryImage(L2);

        B1(isnan(L1))=0;
        B2(isnan(L2))=0;
        
%         B1 = imdilate(B1, ones(3));
        
        maxVal = max(visIm(:));
        visIm = showMaskOnImage(visIm, B1, [0 maxVal 0], 4);
        visIm = showMaskOnImage(visIm, B2, [maxVal 0 0], 4);
        visIm = showMaskOnImage(visIm, B1 & B2, [0 0 maxVal], 4);
        visIm = visIm./maxVal;
        
        figure();
        imshow(visIm, [0 4]);
    end
  
    muse = undersegError;
end
