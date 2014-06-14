clc;
clear;
%% read image
xyloObj = VideoReader('IMG_0786(3).avi');

nFrames = xyloObj.NumberOfFrames;
vidHeight = xyloObj.Height;
vidWidth = xyloObj.Width;

% Preallocate movie structure.
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
           'colormap', []);
       
% Preallocate movie structure.
mov_mosaic(1:nFrames*3) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
           'colormap', []);
       
% Read one frame at a time.
for k = 1 : nFrames
    mov(k).cdata = read(xyloObj, k);
end

%% warping
k=3;
mov_mosaic(k).cdata=mov(1).cdata;

%%
for k = 4 : 50
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 51 : 76
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-20).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 77 : 100
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-40).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 101 : 124
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-60).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 125 : 147
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-80).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 148 : 170
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-110).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 171 : 200
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-130).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 201 : 220
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-150).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 221 : 240
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-170).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 241 : 260
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-195).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 261 : 280
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-205).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 281 : 300
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-215).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 300 : 318
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-230).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%%
for k = 319 : 325
    mosaic = sift_mosaic(mov_mosaic(k-1).cdata, mov(k-250).cdata);
    [h,w]=size(mosaic(:,:,1));
    A=mosaic(:,:,1);
    for i = 1 : h
        if A(i,1)>0
            mov_mosaic(k).cdata=mosaic(i:i+960-1,3:542,1:3);
            break
        end
    end
end
%% write video
writerObj = VideoWriter('mosaic(2).avi');
open(writerObj);

for k = 1 : nFrames*2
    writeVideo(writerObj, mov_mosaic(k));
end
close(writerObj);


