function p = phogDescriptor3(bh,bv,L,bin)
% anna_PHOGDESCRIPTOR Computes Pyramid Histogram of Oriented Gradient over a ROI.
%               
% Modified by Jimei Yang @Adobe, 2013
%IN:
%	bh - matrix of bin histogram values
%	bv - matrix of gradient values 
%   L - number of pyramid levels
%   bin - number of bins
%
%OUT:
%	p - pyramid histogram of oriented gradients (phog descriptor)
nCells = 4.^[0:L];
aCells = cumsum(nCells);
p = zeros(bin*sum(nCells),1);
valid = bh>0;

bh_tmp = bh(valid);
bv_tmp = bv(valid);

if ~isempty(bh_tmp)
    pl = accumarray(bh_tmp(:), bv_tmp(:), [bin,1]);
    p(1:bin) = pl./(sum(pl));
end
        
cella = 1;
for l=1:L
    pl = zeros(bin,4^l);
    cnt = 1;
    x = fix(size(bh,2)/(2^l));
    y = fix(size(bh,1)/(2^l));
    xx=0;
    yy=0;
    xi=1; 
    while xx+x<=size(bh,2) && xi<=2^l
        xi = xi + 1;
        yi=1;
        while yy +y <=size(bh,1) && yi<=2^l
            yi = yi + 1;
            bh_cella = bh(yy+1:yy+y,xx+1:xx+x);
            bv_cella = bv(yy+1:yy+y,xx+1:xx+x);
            valid_cella = valid(yy+1:yy+y,xx+1:xx+x);
            bh_tmp = bh_cella(valid_cella);
            bv_tmp = bv_cella(valid_cella);
            
            if ~isempty(bh_tmp)
                pl_cell = accumarray(bh_tmp(:), bv_tmp(:), [bin,1]);
                pl(:,cnt) = pl_cell;
            end

            yy = yy+y;
            cnt = cnt + 1;
        end        
        cella = cella+1;
        yy = 0;
        xx = xx+x;
    end
    pl = pl(:);
    if sum(pl)~=0
        p(bin*aCells(l)+1:bin*aCells(l+1)) = pl./(sum(pl));
    else
        p(bin*aCells(l)+1:bin*aCells(l+1)) = pl;
    end
end
p = p/(norm(p)+1e-8);

