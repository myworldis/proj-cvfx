clc;
clear;

%% read image
I = imread('mosaic_all.png');

mov(1:210) = ...
    struct('cdata', zeros(240, 135, 3, 'uint8'),...
           'colormap', []);

for k = 1 : 210
    mov(k).cdata=I(1:240,k*3:135+k*3,1:3);
end

%% write video
writerObj = VideoWriter('mosaic_all.avi');
open(writerObj);

for k = 1 : 210
    writeVideo(writerObj, mov(k).cdata);
end
close(writerObj);