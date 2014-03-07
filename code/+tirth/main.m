
addpath('./Weiss_intrinsic/');
 
 
warrn_id = 'images:initSize:adjustingMag';
warning('off',warrn_id)

%%
ROOT = '../data';

f1='IMG_0549.MOV';
f2='IMG_0550.MOV';
f3='IMG_0562.MOV';

v1=VideoReader(fullfile(ROOT,f3) );

num = v1.NumberOfFrames;

%% load some data

frames=zeros(v1.Height,v1.Width,3,0,'uint8');
for k=1:30:num
    frames(:,:,:,end+1) =uint8(read(v1, k));
end
%% save frame

caseName = 'case3';
saveDir = fullfile('../tmp',caseName);
mkdir(saveDir);
 
frames=zeros(v1.Height,v1.Width,3,0,'uint8');
for k=1:5:num
    aframe =uint8(read(v1, k));
    imwrite(aframe,fullfile(saveDir,strcat('f_',num2str(k),'.png')));
    fprintf('pass -%d/%d \n',k,num);
end

%% picl frames 2

sid2 = [6,111,311,381,781,551,526,776,1356];
sid2 = [6:8,111:113,311:312,381:383,781:783,551:553,526:528,776:778,1356:1358];

ratio = 0.25;

ms_f = zeros(size(frames,1)*ratio ,  size(frames,2)*ratio , 3 , 0);
 

for k=1:numel(sid2) 
    aframe =uint8(read(v1, sid2(k)));
    gim = ( double(imresize(aframe,ratio))./255 );
    ms_f(:,:,:, end+1) = gim ; 
end


%% pick frames

ratio = 0.25;

ds_f = zeros(size(frames,1)*ratio ,  size(frames,2)*ratio , 3 , 0);
ds_idx = [];

for k=1:5:size(frames,4)  
    gim = ( double(imresize(frames(:,:,:,k),ratio))./255 );
    ds_f(:,:,:, end+1) = gim ;
    ds_idx(end+1)=k;
end
%% save
 
figure;

for k=1:size(frames,4)
    %imshow(frames(:,:,:,k));
    %title(strcat('frame-',num2str(k)));
    %pause
    imwrite(frames(:,:,:,k),strcat('../tmp/frame-',num2str(k),'.png'));
end

%% vis
figure;

for k=1:size(ds_f,4)
    imshow(ds_f(:,:,:,k));
    title(num2str(k));
    pause 
end

%% manually select

sid = [1,20,29,43,10,37];

msFr =zeros(size(frames,1)*ratio ,  size(frames,2)*ratio , 3 , 0);

for k=1:numel(sid)
    af = frames(:,:,:,sid(k));
    af = double(af)./255;
    msFr(:,:,:,end+1)= imresize(af , ratio);
end

%%


[rimg , limg , gimref , giml1 ]=tirth.rgbWeiss(ms_f);
 
fimshow(tirth.normalize(rimg));
title('reflectance');

fimshow(tirth.normalize(limg));
title('light of frame 1');

%%
fimshow(gimref);
fimshow(giml1);

%%
 
ts = tic;

[imR,dxs,dys,dx,dy,invKhat]=getAlbedo(ds_f);
fimshow(imR);

disp('albedo DONE');

light1=reconsEdge3(dxs(:,:,1)-dx,dys(:,:,1)-dy,invKhat);

disp('light DONE');

toc(ts)


%%

figure(2);
show(imR);
title('reflectance');

% to get lighting we subtract median lighting from the gradient
% and reconstruct

figure(3);
show(light1);
title('lighting frame 1');












