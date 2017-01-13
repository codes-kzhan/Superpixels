% Compute sparse codes
N = length(trainList);

llcK = 5;
load(['Vocabs/siftVocab' num2str(szSiftVocab) '.mat']);

tic
for f = 1:N

    name = trainList{f};
    imfile = [imDir name '.jpg'];
    outputfile = [scodeDir name '.mat'];
    if exist(outputfile,'file')
        continue;
    end
    load([siftDir name '.mat']);
    [ix w] = LLCEncode(single(sifts), single(siftVocab), llcK);
    
    save(outputfile, 'ix', 'w');
    if mod(f,100)==0
        fprintf('LLC: %d image in %f seconds.\n', f, toc);
    end
end
