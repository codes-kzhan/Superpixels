load objcolormap
load basecolormap

X = basecolormap(2:end,:);
Y = objcolormap(2:end,:);

% convert RGB to HSV
X1 = rgb2hsv(X);
Y1 = rgb2hsv(Y);

Z = adjustSaturation(X,10,2);