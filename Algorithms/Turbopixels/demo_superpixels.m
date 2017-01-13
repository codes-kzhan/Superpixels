% Runs the superpixel code on the lizard imageaddpath('lsmlib');
img = im2double(imread('lizard.jpg'));
[phi,boundary,disp_img] = superpixels(img,400);
imwrite(disp_img,'contour.jpg');
imwrite(boundary,'labels.bmp');
imagesc(disp_img);
