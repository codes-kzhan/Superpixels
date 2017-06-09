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
% [It] = applyFlowTransform(I, F, interpMethod)
% 
% Compute transformed image It by applying flow F on pixels of image I.
% 
% Input:
% F             ... four channel image: U (x-motion), V (y-motion), valid, occluded
%                   if empty, zero flow is assumed and It=I
% I             ... input image
%  interpMethod ... 'none', 'nearest', 'linear' 
%                  For 'nearest' and 'linear' TriScatteredInterp
%                  interpolation is used, this is slow and there is no
%                  mechanism to detect if there is no valid flow
%                  information for a pixel (since its interpolated from
%                  surrounding pixel values)
%
% Output:
% It ... transformed image
%
function [It] = applyFlowTransform(I, F, interpMethod)
    if nargin<3
        interpMethod='none';
    end

    if isempty(F)
      It = I;
      return;
    end
    
    % split flow components
    U = double(F(:,:,1));
    V = double(F(:,:,2));
    valid = logical(F(:,:,3)) & ~(logical(F(:,:,4)));
    
    [h w] = size(U);
    % initialize as invalid
    It = nan * ones(size(I));    
   
    if strcmp(interpMethod, 'none_slow')
        
        % apply flow: iterate over L1 and move pixels for that a valid flow
        % vector exists and which are still in the image after the motion
        for x=1:w
            for y=1:h

                if valid(y, x)
                    y_new = round(y+V(y,x));
                    x_new = round(x+U(y,x));
                    if y_new>0 && y_new<=h && x_new>0 && x_new<=w
                        It( y_new, x_new, :) = I(y, x, :);
                    end
                end
            end
        end   
    elseif strcmp(interpMethod, 'none')
        X = repmat([1:w], h,1);
        Y = repmat([1:h]', 1,w);
        Xt = round(X + U);
        Yt = round(Y + V);
        
        c = size(I,3);
        for i=1:c

            Ic = I(:,:,i);
                        
            % remove invalid points, occluded points or points outside image
            insideImIdx = Yt>0 & Yt<=h & Xt>0 & Xt<=w & valid;
            idxt = sub2ind([h w], Yt(insideImIdx), Xt(insideImIdx));
            idx = sub2ind([h w], Y(insideImIdx), X(insideImIdx));
                        
            ICt = nan * ones(h,w);   
            ICt(idxt) = Ic(idx);
            
            It(:,:,i) = ICt;
        end
        
    else  % 'linear', 'nearest'    
        Xt = repmat([1:w], h,1) + U;
        Yt = repmat([1:h]', 1,w) + V;
        
        Xt(~valid) = [];
        Yt(~valid) = [];
        c = size(I,3);
        
        for i=1:c

            Ic = I(:,:,i);
            Ic(~valid)=[];
            
            % since the interp2 function requires that X and Y be monotonic and
            % plaid (as if they were created using MESHGRID) and the
            % transformed coordinates do not hold this assumption, we need a
            % scatter interpolation technique
            TSI = TriScatteredInterp(Xt(:), Yt(:), double(Ic(:)), interpMethod);
            [XI, YI] = meshgrid(1:w, 1:h);
            ZI = TSI(XI, YI);
            
            ICt = nan(h,w);   
%             ICt(valid) = ZI(valid);
            
            % mark all pixels in I2 with no given pixel F(I1) in the direct
            % neighborhood as not defined
            M = zeros(h,w);
            Ytr = round(Yt);
            Xtr = round(Xt);
            insideImIdx = Ytr>0 & Ytr<=h & Xtr>0 & Xtr<=w;
            idx = sub2ind([h w], Ytr(insideImIdx), Xtr(insideImIdx));            
            M(idx) = 1;
            M = logical(imclose(M, ones(3)));
            ICt(M) = ZI(M);
            
            It(:,:,i) = ICt;
        end
        
    end        
        
end
