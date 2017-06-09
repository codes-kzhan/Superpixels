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
% main_benchmark_algorithm(alg_paramfilename, segmentFlag, benchmarkFlag, evaluateFlag)
%
% Run all benchmarks. This may take a long time, a few hours + segmentation of several
% thousand images. Maybe you want to compute just a single or few metrics instead?
%
% params:
% alg_paramfilename    ... input algorithm paramters
% segmentFlag          ... [optional] toggles call of segmentation 
%                          algorithm, default 1
% benchmarkFlag        ... [optional] toggles computation of 
%                          benchmark metricsv, default 1
% evaluateFlag         ... [optional] toggles visualization of 
%                          benchmark results, default 1
%
function main_benchmark_algorithm(alg_paramfilename, segmentFlag, benchmarkFlag, evaluateFlag)
  
  set_paths;

  % ============== parse input  ============== 
  
  if ~exist('segmentFlag', 'var')
    segmentFlag = 1;
  end
  
  if ~exist('benchmarkFlag', 'var')
    benchmarkFlag = 1;
  end
  
  if ~exist('evaluateFlag', 'var')
    evaluateFlag = 1;
  end
  
  replaceFlag = 0; % overwrite existing results?
  sintelFile = 'configs/gtof_sintel_fast.yaml';
  bsdsFile = 'configs/bsds500.yaml';
  
  % ============== BSDS ==============
  if segmentFlag, main_segmentBSDS(alg_paramfilename,  bsdsFile, replaceFlag); end  
  if benchmarkFlag, main_runBenchmarkBSDS(alg_paramfilename,  bsdsFile); end  
  if evaluateFlag, main_evaluateBSDS(alg_paramfilename,  bsdsFile);  end
  
  % ==============  GTOF SINTEL ============== 
  if segmentFlag, main_segmentSintel(alg_paramfilename, sintelFile , replaceFlag); end
  if benchmarkFlag, main_runSintelBenchmarkMDE(alg_paramfilename,  sintelFile); end
  if evaluateFlag, main_evaluateSintelBenchmarkMDE(alg_paramfilename, sintelFile); end
  if benchmarkFlag, main_runSintelBenchmarkMUSE(alg_paramfilename,  sintelFile); end
  if evaluateFlag, main_evaluateSintelBenchmarkMUSE(alg_paramfilename,  sintelFile); end
  
  % ==============  GTOF KITTI ============== 
  if segmentFlag, main_segmentKitti(alg_paramfilename,  'configs/gtof_kitti.yaml', replaceFlag); end  
  if benchmarkFlag, main_runKittiBenchmarkMDE(alg_paramfilename,  'configs/gtof_kitti.yaml'); end
  if evaluateFlag, main_evaluateKittiBenchmarkMDE(alg_paramfilename,  'configs/gtof_kitti.yaml'); end
  if benchmarkFlag, main_runKittiBenchmarkMUSE(alg_paramfilename,  'configs/gtof_kitti.yaml'); end
  if evaluateFlag, main_evaluateKittiBenchmarkMUSE(alg_paramfilename,  'configs/gtof_kitti.yaml'); end

  % ==============  affine ============== 
  affine_set = {'configs/bsds500_affine_shift.yaml', ...
                'configs/bsds500_affine_scale.yaml', ...
                'configs/bsds500_affine_shear.yaml', ...
                'configs/bsds500_affine_rotation.yaml'};

  for i=1:numel(affine_set)
    bsds_affine_paramfilename = affine_set{i};
    
    if segmentFlag, main_segmentBSDS_affine(alg_paramfilename, bsds_affine_paramfilename, replaceFlag); end    
    if benchmarkFlag, main_runBenchmarkBSDS_affine(alg_paramfilename, bsds_affine_paramfilename); end
    if evaluateFlag, main_evaluateBSDS_affine(alg_paramfilename, bsds_affine_paramfilename); end
    
  end
  
  % ==============  Size ============== 
  if benchmarkFlag, main_runBenchmarkSize(alg_paramfilename,  'configs/bsds500.yaml'); end
   if evaluateFlag, main_evaluateSize({alg_paramfilename}, 'configs/bsds500.yaml'); end
  
  % ==============  MASA ============== 
  if benchmarkFlag, main_runBenchmarkMASA(alg_paramfilename,  'configs/bsds500.yaml'); end
   if evaluateFlag, main_evaluateMASA({alg_paramfilename}, 'configs/bsds500.yaml'); end
    
  % ==============  Max overlap ============== 
  % if benchmarkFlag, main_runSintelBenchmarkMaxOverlap(alg_paramfilename, sintelFile); end
  
  % ============== Noise Gauss ============== 
  if segmentFlag, main_segmentNoisyImagesBSDS(alg_paramfilename, 'configs/bsds500_noise_gaus.yaml'); end
  if benchmarkFlag, main_runBenchmarkNoisyImagesBSDS(alg_paramfilename, 'configs/bsds500_noise_gaus.yaml'); end
  if evaluateFlag, main_evaluateNoisyImagesBSDS({alg_paramfilename},  'configs/bsds500_noise_gaus.yaml'); end 
  
  % ==============  Noise Salt and Pepper ============== 
  if segmentFlag, main_segmentNoisyImagesBSDS(alg_paramfilename, 'configs/bsds500_noise_saltAndPepper.yaml'); end
  if benchmarkFlag, main_runBenchmarkNoisyImagesBSDS(alg_paramfilename, 'configs/bsds500_noise_saltAndPepper.yaml'); end
  if evaluateFlag, main_evaluateNoisyImagesBSDS({alg_paramfilename},  'configs/bsds500_noise_saltAndPepper.yaml'); end 
  
  % ==============  Compactness isoperimetric ============== 
  if benchmarkFlag, main_runBenchmarkCompactness(alg_paramfilename,  'configs/bsds500.yaml', 0); end  
   if evaluateFlag, main_evaluateCompactness({alg_paramfilename},  'configs/bsds500.yaml', 'smooth', 0); end  
  
  % ==============  Compactness isoperimetric, smoothed ============== 
  if benchmarkFlag, main_runBenchmarkCompactness(alg_paramfilename,  'configs/bsds500.yaml', 5); end
   if evaluateFlag, main_evaluateCompactness({alg_paramfilename},  'configs/bsds500.yaml', 'smooth', 5); end
  
  % ==============  Compactness isodiaimetric ============== 
  if benchmarkFlag, main_runBenchmarkCompactnessDiameter(alg_paramfilename,  'configs/bsds500.yaml'); end  
  if evaluateFlag, main_evaluateCompactness({alg_paramfilename},  'configs/bsds500.yaml', 'diameterFlag', 1); end
  
    
  
end