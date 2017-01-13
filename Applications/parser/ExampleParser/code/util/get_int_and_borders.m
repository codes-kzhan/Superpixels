function [ int_mask, border ] = get_int_and_borders( mask, in_size, out_size )
%GET_INT_AND_BORDERS Summary of this function goes here
%   Detailed explanation goes here
if(sum(mask(:)==1) == numel(mask))
    mask(1:end,[1 end]) = 0;
    mask([1 end], 1:end) = 0;
end
if in_size > 0
    strEl_in = strel('square',in_size);
    int_mask = imerode(mask,strEl_in,'same');
else
    int_mask = mask;
end
strEl_out = strel('square',out_size);
full_border = double(imdilate(mask,strEl_out,'same')-int_mask);

[y x] = find(full_border);
[r c] = size(full_border);
top = min(y);
bottom = max(y);
left = min(x);
right = max(x);
yVals = repmat((1:r)',1,c);
xVals = repmat(1:c,r,1);
border = zeros([r c 5]);
border(:,:,1) = abs(xVals-left);
border(:,:,2) = abs(xVals-right);
border(:,:,3) = abs(yVals-top);
border(:,:,4) = abs(yVals-bottom);
[foo, index] = min(border(:,:,1:4),[],3);
border(:,:,1) = (index==1).*full_border;
border(:,:,2) = (index==2).*full_border;
border(:,:,3) = (index==3).*full_border;
border(:,:,4) = (index==4).*full_border;