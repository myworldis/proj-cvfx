clc;
clear;
%% read image
% xyloObj = VideoReader('IMG_0795rr.avi');
% xyloObj = VideoReader('IMG_0786s.avi');
xyloObj = VideoReader('./DSCN1610s.avi');
vout=VideoWriter('stabilization.avi','Motion JPEG AVI' );

nFrames = xyloObj.NumberOfFrames
vidHeight = xyloObj.Height;
vidWidth = xyloObj.Width;

% Preallocate movie structure.
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
           'colormap', []);
% Read one frame at a time.
for k = 1 : nFrames/2
    mov(k).cdata = read(xyloObj, k);
end

%% warping
% mosaic = sift_mosaic(mov(1).cdata, mov(2).cdata);
stable = sift_stable(mov(200).cdata, mov(201).cdata);
open(vout); 
for k = 202 : 400%nFrames/2
%     mosaic = sift_mosaic(mosaic, mov(k).cdata);
%     writeVideo(vout, mosaic);
    
%     stable = sift_stable(stable, mov(k).cdata);
    stable = sift_stable_homography(stable, mov(k).cdata);
    writeVideo(vout, stable);
     
    fprintf(' %d/%d\n',k,nFrames);
end
close(vout);
