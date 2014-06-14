clc;
clear;
%% read image
xyloObj = VideoReader('IMG_0786.wmv');

nFrames = xyloObj.NumberOfFrames;
vidHeight = xyloObj.Height;
vidWidth = xyloObj.Width;

% Preallocate movie structure.
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
           'colormap', []);
% Read one frame at a time.
for k = 1 : nFrames
    mov(k).cdata = read(xyloObj, k);
end

%% write image
imwrite(mov(1).cdata,'image1.jpg');
imwrite(mov(11).cdata,'image11.jpg');
imwrite(mov(21).cdata,'image21.jpg');
imwrite(mov(31).cdata,'image31.jpg');
imwrite(mov(41).cdata,'image41.jpg');
imwrite(mov(51).cdata,'image51.jpg');
imwrite(mov(61).cdata,'image61.jpg');
imwrite(mov(71).cdata,'image71.jpg');
imwrite(mov(81).cdata,'image81.jpg');
imwrite(mov(91).cdata,'image91.jpg');
imwrite(mov(101).cdata,'image101.jpg');
imwrite(mov(111).cdata,'image111.jpg');
imwrite(mov(121).cdata,'image121.jpg');
imwrite(mov(131).cdata,'image131.jpg');

%% write video
writerObj = VideoWriter('test.avi');
open(writerObj);

for k = 1 : nFrames
    writeVideo(writerObj, mov(k).cdata);
end
close(writerObj);


