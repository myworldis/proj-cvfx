
addpath('./Weiss_intrinsic/');
 
 
warrn_id = 'images:initSize:adjustingMag';
warning('off',warrn_id)
 

%%
ROOT = '../data';

f1='IMG_0549.MOV'; 

v1=VideoReader(fullfile(ROOT,f1) );

num = v1.NumberOfFrames;
vWidth = v1.Width;
vHeight = v1.Height; 

%% pick frames 2
 

sid2 = [196,1406,311];

ratio = 720/1080;

ms_f = zeros( vHeight*ratio ,  vWidth*ratio , 3 , 0);
 

for k=1:numel(sid2) 
    aframe =uint8(read(v1, sid2(k)));
    gim = ( double(imresize(aframe,ratio)) ./ 255 );
    ms_f(:,:,:, end+1) = gim ; 
end
 
disp('load done');
   
%% RUN

shiftc= 1e-6;
% tx to LOG donmain
targetTmp = ms_f;
targetTmp = targetTmp + shiftc;
targetFrs = log(targetTmp);
 
fprintf('# of frames = %d \n', size(targetFrs,4));

[rimg , limg , calData ]=tirth.rgbWeiss(targetFrs);
 

%% VIS result

ori_rimg=(exp(rimg));
ori_limg=(exp(limg));

fimshow(ori_rimg,'border','tight');
title('reflectance');

fimshow(max(tirth.normalize(ori_limg),[],3));

%fimshow(ori_limg,'border','tight');
title('light of frame 1');


%% reconstruct


comp=exp(rimg+limg);

fimshow(tirth.clamp(comp));
title('comp');  
  


%% reconstruct
 
fimshowpair(ms_f(:,:,:,1)+shiftc, tirth.clamp(comp) ,'diff');
fimshowpair(ms_f(:,:,:,1)+shiftc, tirth.clamp(comp)-shiftc );

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






