
addpath('./Weiss_intrinsic/');
 
 
warrn_id = 'images:initSize:adjustingMag';
warning('off',warrn_id)

%%

bkMask = imread('../bk_mask.png');
bkMask = bkMask(:,:,1) ==0;

%%
ROOT = '../data';

f1='IMG_0549.MOV';
f2='IMG_0550.MOV';
f3='IMG_0562.MOV';

v1=VideoReader(fullfile(ROOT,f1) );

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

%% pick frames 2

sid2 = [6,111,311,381,781,551,526,776,1356];
%sid2 = [6:8,111:113,311:312,381:383,781:783,551:553,526:528,776:778,1356:1358];

sid2 = [196,1406,311];

ratio = 0.25;

ms_f = zeros(size(frames,1)*ratio ,  size(frames,2)*ratio , 3 , 0);
 

for k=1:numel(sid2) 
    aframe =uint8(read(v1, sid2(k)));
    gim = ( double(imresize(aframe,ratio))./255 );
    ms_f(:,:,:, end+1) = gim ; 
end
 
disp('load done');

%%

imwrite( ms_f(:,:,:,1)  , '../bk.png');

%% vis
figure;

for k=1:size(ms_f,4)
    imshow(ms_f(:,:,:,k));
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

%% RUN

[rimg , limg , gimref , giml1 ]=tirth.rgbWeiss(ms_f);

%%

rimg_1d = reshape(tirth.normalize(rimg),[],3);
ori_1d = reshape(ms_f(:,:,:,1) , [],3);
rimg_1d(bkMask,:)=ori_1d(bkMask, : );

rimg2 = reshape( rimg_1d , size(rimg) );
fimshow(rimg2);


%% 

figure;
show(tirth.normalize(rimg));

%% VIS result
fimshow(tirth.normalize(rimg));
title('reflectance');

fimshow(tirth.normalize(limg));
title('light of frame 1');

%% reconstruct

comp=exp(log(rimg)+log(limg));
comp2=real(comp); 
comp2(comp2<0)=0;
fimshowpair(ms_f(:,:,:,1), tirth.normalize(comp2) );

title('re-comstruct');

%% getstroke

strokeMask = tirth.getDraw(ms_f(:,:,:,1));

%% composition

bkpixel = rimg(213,205,:);

rimg2=rimg;
rimg2=reshape(rimg2,[],3);

rimg2(strokeMask,1)=bkpixel(1);
rimg2(strokeMask,2)=bkpixel(2);
rimg2(strokeMask,3)=bkpixel(3);

rimg2=reshape(rimg2,size(rimg));

fimshowpair(tirth.normalize(rimg),tirth.normalize(rimg2));

%%
comp=exp(log(rimg2)+log(limg));
comp2=real(comp); 
comp2(comp2<0)=0;
fimshowpair(ms_f(:,:,:,1), tirth.normalize(comp2) );

title('re-compose');








