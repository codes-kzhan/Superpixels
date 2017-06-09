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
% main_segmentBSDS_affine(alg_paramfilename, bsds_affine_paramfilename, replaceFlag)
%
% Load benchmark parameter file and affine parameter file
% and segment images using their benchmark setting. Results are
% stored to disk
% 
% Input:
% alg_paramfilename ... algorithm parameter file (YAML)
% bsds_affine_paramfilename ... dataset parameter file (YAML)
% replaceFlag ... overwrite results if already exist (default 1)
%
function main_segmentBSDS_affine(alg_paramfilename, bsds_affine_paramfilename, replaceFlag)
    
    if ~exist('replaceFlag','var'), replaceFlag=1; end

    fprintf('main_segmentBSDS_affine: %s and %s\n', alg_paramfilename, bsds_affine_paramfilename);


    %% load benchmark parameter files 
    params = ReadYaml(alg_paramfilename);
    bsds_affine_params = ReadYaml(bsds_affine_paramfilename);
    addpath(params.segParams.path);
    
    
    %% load benchmark images (images and their names)
    fprintf('\t'); 
    [images, ~, names] = loadBSDS500( bsds_affine_params.BSDS500_root,...
                                      bsds_affine_params.mode, ...
                                      bsds_affine_params.nImages);
    
    %% draw border of zeros arround each image to compensate for effects
    %% caused by borders of zeros introduced by affine transformations
    bSize=10;
    for i=1:length(images)       
       images{i} =  [zeros(size(images{i},1),bSize,size(images{i},3)), images{i}, zeros(size(images{i},1),bSize,size(images{i},3))]; % cols
       images{i} =  [zeros(bSize, size(images{i},2),size(images{i},3)); images{i}; zeros(bSize, size(images{i},2),size(images{i},3))]; % rows
    end
    
    %% process each parameterset (run algorithm)
    for s=1:numel(params.segParams.set)
      
        % skip if this is not the oneShotSet indicated by oneShotSetName
        if ~strcmp(params.segParams.set{s}.name, params.segParams.oneShotSetName)
          continue;
        end
        
        fprintf('\tWorking on paramset: %s\t', params.segParams.set{s}.name);
        
        % create result folder
        savePathBase =  fullfile( params.segSaveDir, ...
                                  bsds_affine_params.id, ...
                                  params.id, ...
                                  params.segParams.set{s}.name); 
        mkdirCheck(savePathBase);
    
        % create storage for original images
        savePathOriginal = fullfile(savePathBase, 'original');
        mkdirCheck(savePathOriginal);
                
        % create storage for transformed images
        for affineSet_idx=1:length(bsds_affine_params.affine_trafo)            
            savePathAffine = fullfile(savePathBase, bsds_affine_params.affine_trafo{affineSet_idx}.name);
            mkdirCheck(savePathAffine);
        end
                
        % - run on image
        % - transform image
        % - run on transformed image
        % - retransform result
        % (- compare) 
        % - save
                
        % for each image        
        reverseStr = [];
        for i=1:length(images)
            reverseStr = printProgress('(All trafos on image %d of %d)\n', i, length(images), reverseStr);

            savePath = fullfile(savePathOriginal, [(names{i}) '.png']);  
            
            % skip if image already exists
            if ~replaceFlag && exist( savePath, 'file' )
              % skip
            else

              I = images{i};

              % save temporarly for algorithms that do not use "I" but load from file
              I_path = fullfile(savePathOriginal, 'temp.png');
              imwrite(I, I_path);

              % segment: compute L and t from I 
              %   - input is "I" (color, [0, 255])
              %   - segmentation result is in "L" (integer)
              %   - runtime is stored in"t"
              eval(params.segParams.segFct);

              % save resulting segment image
              imwrite(L, savePath, 'bitdepth', 16);
            end  
              
            % run on transformed images
            for j=1:length(bsds_affine_params.affine_trafo)
              
                savePath = fullfile(savePathBase, bsds_affine_params.affine_trafo{j}.name, [(names{i}) '.png']);            
              
                % skip if image already exists
                if ~replaceFlag && exist( savePath, 'file' )
                  continue;
                end
            
              
                % get current transformation and apply on image
                A = cell2mat(bsds_affine_params.affine_trafo{j}.T);
                I = applyTransform(images{i}, A);                
                
                % save temporarly for algorithms that do not use "I" but load from file
                I_path = fullfile(savePathOriginal, 'temp.png');
                imwrite(I, I_path);
                
                % segment: compute L and t from I 
                %   - input is "I" (color, [0, 255])
                %   - segmentation result is in "L" (integer)
                %   - runtime is stored in"t"
                eval(params.segParams.segFct);
                
                % retransform
                L_retransformed = applyTransform(L, inv(A));
                
                % crop
                [h1 w1 c1] = size(images{i});
                [h2 w2 c2] = size(L_retransformed);
                x1 = round( 1-w1/2+w2/2 );
                y1 = round( 1-h1/2+h2/2 );
                x2 = round( w1-w1/2+w2/2 );
                y2 = round( h1-h1/2+h2/2 );
                               
                L_cropped = L_retransformed( y1:y2, x1:x2 );
                
                % save                
                imwrite(L_cropped, savePath, 'bitdepth', 16);
                
            end
            
        end

    end
    
end

