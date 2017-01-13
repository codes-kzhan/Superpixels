N = numel(trainList);
M = round(300000/N);

all_sifts = zeros(128, N*M, 'uint8');
for f = 1:N
    name = trainList{f};
    siftfile = [siftDir name '.mat'];
    load(siftfile);
    if size(sifts,2) < M
        sifts = repmat(sifts, 1, ceil(M/size(sifts,2)));
    end
    all_sifts(:,(f-1)*M+1:f*M) = vl_colsubset(sifts,M);   
end

[siftVocab ind] = vl_ikmeans(all_sifts,szSiftVocab);

path = ['Vocabs/siftVocab' num2str(szSiftVocab) '.mat'];
save(path,'siftVocab','ind');
