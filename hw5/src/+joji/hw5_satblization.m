
%% read image
xyloObj = VideoReader('IMG_0795rr.avi');
% xyloObj = VideoReader('IMG_0786s.avi');
vout=VideoWriter('stabilization.avi','Motion JPEG AVI' );

nFrames = xyloObj.NumberOfFrames
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

%% warping
% mosaic = sift_mosaic(mov(1).cdata, mov(2).cdata);
stable = sift_stable(mov(1).cdata, mov(2).cdata);
open(vout); 
for k = 3 : nFrames/2
%     mosaic = sift_mosaic(mosaic, mov(k).cdata);
%     writeVideo(vout, mosaic);
    
    stable = sift_stable(stable, mov(k).cdata);
    writeVideo(vout, stable);
     
    fprintf(' %d/%d\n',k,nFrames);
end
disp('STABILIZE done');
close(vout);
