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
% Visualizes a Sintel segmentation
%
function showSintelSegmenation(alg_paramfilename, sintel_paramfilename, paremsetIdx, sceneIdx, imIdx)
  set_paths;
  
  % parse parameter files
  params = ReadYaml(alg_paramfilename);
  sintel_params = ReadYaml(sintel_paramfilename);

  sintel = getSintelImage(sintel_params.sintelPath,...  
                            'nScenes', sintel_params.nSintelScenes, ...
                            'nImagesPerScene', sintel_params.nImagesPerScene, ...
                            'renderType', sintel_params.renderType);
     
  savepath1 = fullfile(params.segSaveDir, ...
                       sintel_params.id, ...
                       params.id, ...
                       params.segParams.set{paremsetIdx}.name, ...
                       sprintf('%s_frame_%04d.png', sintel(sceneIdx).name, imIdx));
  L1 = imread(savepath1);
  
  figure(); imshow(L1,[]); colormap(rand(10000,3));