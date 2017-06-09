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
% [U V valid occluded] = getCombinedFlowField(SINTEL_PATH, scene, startIdx, endIdx, visFlag)
% 
% Read all flowfields from image index startIdx to endIdx and combine them
% in a single flow field.
% 
% Input:
% SINTEL_PATH ... Path to Sintel dataset (use set_paths.m)
% scene       ... Sintel scene index
% startIdx    ... index of first image to use from the Sintel scene
% endIdx      ... index of last image to use from the Sintel scene
% visFlag     ... trigger visualization
%  
% Output:
% U     ... combined motion in x direction
% V     ... combined motion in y direction
% valid ... combined valid mask 
%
function [U V valid occluded] = getCombinedFlowField(SINTEL_PATH, scene, startIdx, endIdx, visFlag)
    
    if nargin<5
        visFlag = 0;
    end
    
    % load data
    for i=startIdx:(endIdx-1)
        data(i).F = readFlowFile(fullfile(SINTEL_PATH, 'training', 'flow', scene, sprintf('frame_%0.4d.flo', i)));
        data(i).valid = double(1-imread(fullfile(SINTEL_PATH, 'training', 'invalid', scene, sprintf('frame_%0.4d.png', i))));
        data(i).occluded = double(imread(fullfile(SINTEL_PATH, 'training', 'occlusions', scene, sprintf('frame_%0.4d.png', i))));    
    end

    % successively combine flows
    F = data(startIdx).F;
    U = data(startIdx).F(:,:,1);
    V = data(startIdx).F(:,:,2);
    valid = data(startIdx).valid;
    occluded = data(startIdx).occluded;
    for i=(startIdx+1):(endIdx-1)
         [U V valid occluded] = combineTwoFlowFields(F(:,:,1),         F(:,:,2),         valid,         occluded, ...
                                                     data(i).F(:,:,1), data(i).F(:,:,2), data(i).valid, data(i).occluded);                                                 
         F = cat(3,U,V);         
    end
    
    % visualiization for function test
    if visFlag
        I1 = imread(fullfile(SINTEL_PATH, 'training', 'final', scene, sprintf('frame_%0.4d.png', startIdx)));
        I2 = imread(fullfile(SINTEL_PATH, 'training', 'final', scene, sprintf('frame_%0.4d.png', endIdx)));

        % apply flow on image    
        fprintf('Apply flow\n');
        F_final = cat(3, F, valid, occluded);
        I1T = applyFlowTransform(I1, F_final, 'linear');
        M = isnan(I1T);
        I1T = uint8(I1T);

        % visualize
        figure(); imshow(I1T);
        figure(); imshow(I2);
    end

end

% combine two flows fields
function [U V valid occluded] = combineTwoFlowFields(U1, V1, valid1, occluded1, U2, V2, valid2, occluded2)
    
    
    [h w] = size(U1);
    
    U = zeros(h,w,1);
    V = zeros(h,w,1);
    valid = ones(h,w,1);
    occluded = ones(h,w,1);
    
    for x1=1:w
        for y1=1:h
            
            if valid1(y1,x1) && ~occluded1(y1,x1)
                valid(y1,x1)=1;
                y2 = round(y1+V1(y1,x1));
                x2 = round(x1+U1(y1,x1));
                   
                if y2>0 && y2<=h && x2>0 && x2<w
                    if valid2( y2,x2) && ~occluded2(y2,x2)
                        y3 = round(y2 + V2(y2, x2));
                        x3 = round(x2 + U2(y2, x2));

                        U(y1, x1) = U1(y1,x1) + U2(y2,x2);
                        V(y1, x1) = V1(y1,x1) + V2(y2,x2);
                        
                        if y3>0 && y3<=h && x3>0 && x3<w
                            occluded(y1,x1) = 0;
                        else
                            valid(y1,x1)=0;  
                        end
                    else
                        valid(y1,x1)=0;  

                        % Occluded: indicates for each pixel in I1 if it is occluded in I2 → thus its flow information sholud not be uses 
                        if occluded2(y2,x2)
                            occluded(y1,x1)=1;
                        else
                            occluded(y1,x1)=0;
                        end
                    end
                else
                    valid(y1,x1)=0;
                end
            else
                valid(y1,x1)=0;  
                
                % Occluded: indicates for each pixel in I1 if it is occluded in I2 → thus its flow information sholud not be uses 
                if occluded1(y1,x1)
                    occluded(y1,x1)=1;
                else
                    occluded(y1,x1)=0;
                end
            end
                
        end
    end
end