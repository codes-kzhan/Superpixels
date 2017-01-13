% load query features

load([descrDir query '.mat']);
load([segDir query '.mat']);

descrs = [cell2mat(descrs)];
descrsContext = [cell2mat(descrsContext)];
feaQR = single([descrs;descrsContext]);

if strcmp(kernel, 'Chi2')
    feaQR = vl_homkermap(feaQR, 1, 'KChi2', 'Gamma', 0.7);
end
if strcmp(kernel, 'Inters')
    feaQR = vl_homkermap(feaQR, 1, 'KINTERS', 'Gamma', 0.7);
end
if strcmp(kernel, 'Hellinger')
    feaQR = sqrt(abs(feaQR));
end