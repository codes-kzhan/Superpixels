function phog_arr = phog2(bh, bv, windows, pars)

% Modified by Jimei Yang @Adobe, 2013

if nargin < 4
    pars = [8,360,2];
end

num_windows = size(windows,2);
obin = pars(1); angle = pars(2); L = pars(3);
sbin = 2.^(0:L);
phog_arr = zeros(obin*sum(sbin.^2),num_windows);

% calculate phog descriptors for each window
for ii = 1 : num_windows
    
    win = windows(:,ii);
    roi = [win(2),win(4),win(1),win(3)];
    
%     rs = mod(roi(2)-roi(1)+1,sbin(L+1));
%     if rs~=0
%         ypad = sbin(L+1)-rs;
%     end
    
    bh_roi = bh(roi(1):roi(2),roi(3):roi(4)); 
    
    bv_roi = bv(roi(1):roi(2),roi(3):roi(4));
    
%     descr = phogDescriptor2(bh_roi,bv_roi,L,obin);
    descr = phogDescriptor3(bh_roi,bv_roi,L,obin);
    phog_arr(:,ii) = descr;

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = pad(x, D)

[nrows, ncols, cols] = size(sift_arr);
hgt = nrows+2*D;
wid = ncols+2*D;
PADVAL = 0;

x = [repmat(PADVAL, [hgt Dx cols]) ...
    [repmat(PADVAL, [Dy ncols cols]); x; repmat(PADVAL, [Dy-1 ncols cols])] ...
    repmat(PADVAL, [hgt Dx-1 cols])];

