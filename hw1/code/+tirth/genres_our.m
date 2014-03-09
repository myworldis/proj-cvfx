% test data

imgs={};
imgs{end+1}=imread('../data/new2/DSCN1208.JPG');
imgs{end+1}=imread('../data/new2/DSCN1209.JPG');
imgs{end+1}=imread('../data/new2/DSCN1210.JPG');
imgs{end+1}=imread('../data/new2/DSCN1211.JPG');
imgs{end+1}=imread('../data/new2/DSCN1212.JPG');

disp('load done'); 

%% load video data

v1=VideoReader('../data/new2/DSCN1213.MOV');

num = v1.NumberOfFrames;
vWidth = v1.Width;
vHeight = v1.Height;
 
disp('done');
%% pick frame

sid2 = round([num*0.1,num*0.3,num*0.7,num*0.9]);
ratio = 0.5;

fSample = zeros( vHeight*ratio ,  vWidth*ratio , 3 , 0);

for k=1:numel(sid2) 
    aframe =uint8(read(v1, sid2(k)));
    gim = ( double(imresize(aframe,ratio))./255 );
    fSample(:,:,:, end+1) = gim ; 
end

disp('done');

%% vis 
figure
for k=1:size(fSample,4)
    imshow(fSample(:,:,:,k));
    pause;
end
  
%% RUN
 
targetImgs = fSample;
fprintf('# of frames = %d \n', size(targetImgs,4));
[rimg , limg ,calData]=tirth.rgbWeiss(targetImgs);

%%
fimshow(rimg);
title('reflectance');

fimshow(limg);
title('light of frame 1');
 

%% save
imwrite(rimg, '../data/rimg_our_1080p.png');
  
%%
% log domain -> so some value of light img would be negative
comp=rimg+limg;

comp(comp>1)=1;
comp(comp<0)=0;
%fimshowpair(targetImgs(:,:,:,1), tirth.normalize(comp2) );
fimshowpair(targetImgs(:,:,:,1), (comp) );

fimshow(comp);
title('re-comstruct');

%% remove border
comp2_rmb = comp(3:end-2,3:end-2,:); 
fimshow( (comp2_rmb) );


%% composed 

retouchRimg=imread('../data/rimg_our_rt_1080p.png');
retouchRimg = double(retouchRimg)./255;


retouchRimg2=imresize(retouchRimg,ratio);

comp=retouchRimg2+limg;

%fimshowpair(targetImgs(:,:,:,1), (comp) );
fimshow(comp,'border','tight');
title('recompose');

%% reconstruct ALL
 
vinFname = '../data/new2/DSCN1213.MOV';
voutFname ='../res/our_comp_impv1_final_cpr';

vin=VideoReader( vinFname); 
vout=VideoWriter( voutFname , 'MPEG-4');  

rimgFname='../data/test_rt_new_our.png';
rbkFname='../data/test_rt_bk_our.png';

open(vout); 
tirth.reconstrAll_mat(vout,vin,rimg,rimgFname,rbkFname,calData , ratio);
close(vout);

%% save light of frame 1 and ref

imwrite(tirth.clamp(rimg,1,0),'../res/our_ref.png');
imwrite(tirth.clamp(limg,1,0),'../res/our_ligf1.png');

imwrite(tirth.normalize(real(exp(rimg))),'../res/our_ref_n.png');
imwrite(tirth.normalize(real(exp(limg))),'../res/our_ligf1_n.png');

disp('sav done');

