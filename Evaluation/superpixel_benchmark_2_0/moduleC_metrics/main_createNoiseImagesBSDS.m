% Superpixel Benchmark
% Copyright (C) 2012  Peer Neubert, peer.neubert@etit.tu-chemnitz.de
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
% runAlgorithmAffine(filenameBPF, filenameAPF)
%
% Load benchmark parameter file and affine parameter file
% and segment images using their benchmark setting. Results are
% stored to disk
% 
% filenameBPF ... input benchmark parameter filename (bpf-file)
% filenameAPF ... input affine parameter filename (apf-file)
%
function main_createNoiseImagesBSDS(bsds_noise_paramfilename)
    

    fprintf('main_createNoiseImagesBSDS: %s\n', bsds_noise_paramfilename);


    %% load benchmark parameter files 
    noiseParams = ReadYaml(bsds_noise_paramfilename);
    
    
    %% load benchmark images (images and their names)
    fprintf('\t'); 
    [images, ~, names] = loadBSDS500( noiseParams.BSDS500_root,...
                                      noiseParams.mode, ...
                                      noiseParams.nImages);
    
      
    %% process each parameterset 
    for nIdx=1:numel(noiseParams.noiseSet)
              
        fprintf('\tWorking on paramset: %s\t', noiseParams.noiseSet{nIdx}.name);
        
        % create result folder
        savePathBase =  fullfile( noiseParams.noiseImageSaveDir, ...
                                  noiseParams.id, ...
                                  'noisy_images', ...
                                  noiseParams.noiseSet{nIdx}.name); 
        mkdirCheck(savePathBase);
    
        % for each image        
        reverseStr = [];
        for i=1:length(images)
            reverseStr = printProgress('(Create noise image %d of %d)\n', i, length(images), reverseStr);

            savePath = fullfile(savePathBase, [(names{i}) '.png']);  
            
            I = images{i};             

            % segment: compute noise image J from I 
            eval(noiseParams.createNoisyImageFct);

            % save resulting segment image
            imwrite(J, savePath);
            
        end
    end
    
end

