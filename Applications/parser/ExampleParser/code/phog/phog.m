function phog_arr = phog(I, windows, pars)

I = double(I);
I = mean(I,3);
I = I /max(I(:));
if nargin < 3
    pars = [8,360,2];
end

num_windows = size(windows,2);
obin = pars(1); angle = pars(2); L = pars(3);
sbin = 2.^(0:L);
phog_arr = zeros(obin*sum(sbin.^2),num_windows);

% filtering
E = edge(I,'canny');
[GradientX,GradientY] = gradient(double(I));
GradientYY = gradient(GradientY);
Gr = sqrt((GradientX.*GradientX)+(GradientY.*GradientY));

index = GradientX == 0;
GradientX(index) = 1e-5;

YX = GradientY./GradientX;
if angle == 180, A = ((atan(YX)+(pi/2))*180)/pi; end
if angle == 360, A = ((atan2(GradientY,GradientX)+pi)*180)/pi; end

[bh bv] = anna_binMatrix(A,E,Gr,angle,obin);

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
    
    descr = phogDescriptor(bh_roi,bv_roi,L,obin);
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

