clear all;
clc;
close all;

label=SOM_mex(I,superpixelNum);

DisplaySuperpixel(label,img,name);
DisplayLabel(label,name);