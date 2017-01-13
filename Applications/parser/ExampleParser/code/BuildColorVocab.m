% train color vocabulary
N = numel(trainList);
M = round(300000/N);

all_colors = zeros(3, N*M, 'uint8');

for i = 1:N
    imfile = [imDir trainList{i} '.jpg'];
    im = imread(imfile);
    if size(im,3)==1
        im = cat(3,im,im,im);
    end
    colors = reshape(shiftdim(im,2),[3 size(im,1)*size(im,2)]);
    all_colors(:,(i-1)*M+1:i*M) = vl_colsubset(colors,M); 
end

colorVocab = vl_ikmeans(all_colors,szColorVocab);
outpath = ['Vocabs/colorVocab' num2str(szColorVocab) '.mat']

save(outpath,'colorVocab');
