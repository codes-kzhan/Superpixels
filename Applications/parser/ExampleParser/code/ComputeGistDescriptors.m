% Compute GIST image descriptors for image retrieval

try 
    load(gistDir);
catch
    N = length(trainList);
    GistDB = cell(1,N);
    tic;
    for f = 1:N
        name = trainList{f};
        imfile = [imDir name '.jpg'];
        im = imread(imfile);
        gist = im2gist(im);
        GistDB{f} = gist(:);
        if mod(f,100)==0
            fprintf('Gist: %d image in %f seconds.\n', f, toc);
        end
    end
    GistDB = cell2mat(GistDB);
    GistDB = single(GistDB);
    save(gistDir, 'GistDB');
end