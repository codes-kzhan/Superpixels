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
% sintel = getSintelImage(SINTEL_PATH, varargin)
% 
% Create paths to Sintel images. Use set_paths to get SINTEL_PATH.
%
% Input:
% 'renderType'      ... Sintel rendering type: 'final', 'clean', 'albedo'
% 'nScene'          ... number of Sintel scenes (1 to 23)
% 'nImagesPerScene' ... maximum number of images per scene (1 to 50)
%
% Output:
% sintel(i).images(j).path ... path to image j of sintel scene i
%
function sintel = getSintelImage(SINTEL_PATH, varargin)
   
    %% -------- parse input ---------
    p = inputParser;    
    p.addOptional('renderType','final');
    p.addOptional('nScenes',23);
    p.addOptional('nImagesPerScene',50);

    
    % parse
    p.parse(varargin{:})
    params = p.Results;
    
    % get all scene directories
    sintel = [];
    d = dir(fullfile(SINTEL_PATH, 'training', params.renderType,'*_*'));      
    for i=1:min(params.nScenes, numel(d))        
        sintel(i).name = d(i).name;
        % get all images
        nImages = numel(dir(fullfile(SINTEL_PATH, 'training', params.renderType,sintel(i).name,'frame_*.png')));          
        for j=1:min(params.nImagesPerScene, nImages)
            sintel(i).images(j).path = fullfile(SINTEL_PATH, 'training', params.renderType, d(i).name, sprintf('frame_%04d.png', j));
        end        
    end
    
end