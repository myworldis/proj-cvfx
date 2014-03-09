
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
 
sid2 = [6,111,311,381,781,551,526,776,1356,196,1406,311];

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

targetFrs=ms_f;

fprintf('# of frames = %d \n', size(targetFrs,4));

[rimg , limg , calData ]=tirth.rgbWeiss(targetFrs);
 

%% VIS result

ori_rimg=((rimg));
ori_limg=((limg));

fimshow(ori_rimg,'border','tight');
title('reflectance');

fimshow(max(tirth.normalize(ori_limg),[],3));

%fimshow(ori_limg,'border','tight');
title('light of frame 1');


%% reconstruct


comp=(rimg+limg);

fimshow(tirth.clamp(comp));
title('comp');  
  
 
%% composition 

imwrite(rimg,'../data/rimgta_ori_1080p.png');

%%

max_sat = max(rimg,[],3);

max_limg = max(limg,[],3);

rimg2=imread('../data/rimgta_rt_1080p.png');
rimg2=double(rimg2)./255;
comp=rimg2+limg;
fimshowpair(ms_f(:,:,:,1), comp );

title('re-compose');

%% 
  
vinFname = '../data/IMG_0549.MOV';
voutFname ='../res/ta_comp_impv1_final_crp.mp4';

retouchRimg = double(imread('../data/rimgta_rt_1080p.png'))./255;

vin=VideoReader( vinFname); 
vout=VideoWriter( voutFname , 'MPEG-4'); 

retouchRimg=imresize(retouchRimg,ratio);

rimgFname='../data/test_rt_new_ta.png';
rbkFname='../data/test_rt_bk_ta.png';

open(vout); 
tirth.reconstrAll_mat(vout,vin,rimg,rimgFname,rbkFname,calData , ratio);
close(vout);

disp('DONE-close vout');

%%

 
imwrite(tirth.clamp(rimg,1,0),'../res/ta_ref.png');
imwrite(tirth.clamp(limg,1,0),'../res/ta_ligf1.png');
imwrite(tirth.normalize(rimg),'../res/ta_ref_n.png');
imwrite(tirth.normalize(limg),'../res/ta_ligf1_n.png');

disp('sav done');






