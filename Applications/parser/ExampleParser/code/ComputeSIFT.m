% Compute SIFT descriptors
N = length(trainList);

tic
for f = 1:N

    name = trainList{f};
    imfile = [imDir name '.jpg'];
    outputfile = [siftDir name '.mat'];
    if exist(outputfile,'file')
        continue;
    end
   im = imread(imfile);
   imsize = size(im);
   if length(imsize)<3
       im = cat(3,im,im,im);
   end
   [frames sifts] = vl_phow(single(rgb2gray(im)),'Step',4);
   imsize = imsize(1:2);

   save(outputfile, 'sifts', 'frames', 'imsize');
   if mod(f,100)==0
    fprintf('SIFT: %d image in %f seconds.\n', f, toc);
   end
end
