function [bh, bv] = phogGradients(I, pars)

% Modified by Jimei Yang @Adobe, 2013

I = double(I);
I = mean(I,3);
I = I /max(I(:));
if nargin < 2
    pars = [8,360,2];
end

obin = pars(1); angle = pars(2); L = pars(3);
sbin = 2.^(0:L);

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

[bh, bv] = anna_binMatrix(A,E,Gr,angle,obin);