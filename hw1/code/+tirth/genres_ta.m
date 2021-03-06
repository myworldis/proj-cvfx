
addpath('./Weiss_intrinsic/');
 
 
warrn_id = 'images:initSize:adjustingMag';
warning('off',warrn_id)
 

%%
ROOT = '../data';

f1='IMG_0549.MOV';
f2='IMG_0550.MOV';
f3='IMG_0562.MOV';

v1=VideoReader(fullfile(ROOT,f1) );

num = v1.NumberOfFrames;
vWidth = v1.Width;
vHeight = v1.Height;
 
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

%sid2 = [6:8,111:113,311:312,381:383,781:783,551:553,526:528,776:778,1356:1358];
sid2 = [6,111,311,381,781,551,526,776,1356];

sid2 = [196,1406,311];

ratio = 720/1080;

ms_f = zeros( vHeight*ratio ,  vWidth*ratio , 3 , 0);
 

for k=1:numel(sid2) 
    aframe =uint8(read(v1, sid2(k)));
    gim = ( double(imresize(aframe,ratio))./255 );
    ms_f(:,:,:, end+1) = gim ; 
end
 
disp('load done');
 
% borader handle

targetF2 = ms_f;%Weiss_intrinsic.zeroB(targetFrames);
 
 

%% vis
figure;

for k=1:size(ms_f,4)
    imshow(ms_f(:,:,:,k));
    title(num2str(k));
    pause 
end
 
%% RUN

fprintf('# of frames = %d \n', size(targetF2,4));

[rimg , limg , calData ]=tirth.rgbWeiss(targetF2);
 

%% VIS result
fimshow((rimg),'border','tight');
title('reflectance');

fimshow((limg),'border','tight');
title('light of frame 1');

%% reconstruct

comp=rimg+limg;
fimshowpair(ms_f(:,:,:,1), comp );

title('re-comstruct');
  
%% composition 

imwrite(rimg,'../data/rimgta_ori_1080p.png');
 


%%

rimg2=imread('../data/rimgta_rt_1080p.png');
rimg2=double(rimg2)./255;
comp=rimg2+limg;
fimshowpair(ms_f(:,:,:,1), comp );

title('re-compose');

%% 
  
vinFname = '../data/IMG_0549.MOV';
voutFname ='../res/ta_comp_2_final.avi';

retouchRimg = double(imread('../data/rimgta_rt_1080p.png'))./255;

vin=VideoReader( vinFname); 
vout=VideoWriter( voutFname, 'Uncompressed AVI' ); 

retouchRimg=imresize(retouchRimg,ratio);


open(vout);
tirth.reconstrAll(vout,vin, retouchRimg ,calData , ratio );

close(vout);

disp('DONE-close vout');

%%

 
imwrite(tirth.clamp(rimg,1,0),'../res/ta_ref.png');
imwrite(tirth.clamp(limg,1,0),'../res/ta_ligf1.png');
imwrite(tirth.normalize(rimg),'../res/ta_ref_n.png');
imwrite(tirth.normalize(limg),'../res/ta_ligf1_n.png');

disp('sav done');






