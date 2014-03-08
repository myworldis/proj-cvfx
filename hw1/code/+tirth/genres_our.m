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

%%

ratio = 0.35;

smImgs=zeros(size(imgs{1},1)*ratio,size(imgs{2},2)*ratio,3,0);

for k=1:numel(imgs)
    
    aim = ( double(imresize(imgs{k},ratio))./255 );
    smImgs(:,:,:,end+1)=aim;
end

disp('done');
 
 
%% RUN
 
targetImgs = fSample;
fprintf('# of frames = %d \n', size(targetImgs,4));
[rimg , limg ,calData]=tirth.rgbWeiss(targetImgs);

%%
fimshow(tirth.normalize(rimg));
title('reflectance');

fimshow(tirth.normalize(limg));
title('light of frame 1');
 

%% save

imwrite(rimg, '../data/rimg_our_ori.png');
  
%%
% log domain
comp=rimg+limg;

comp(comp<0)=0;
%fimshowpair(targetImgs(:,:,:,1), tirth.normalize(comp2) );
fimshowpair(targetImgs(:,:,:,1), (comp) );

fimshow(comp);
title('re-comstruct');

%% remove border
comp2_rmb = comp(3:end-2,3:end-2,:); 
fimshow( (comp2_rmb) );

%% composed 

rimg_ret=imread('../data/rimg_our4.png');
rimg_ret = double(rimg_ret)./255;
comp=rimg_ret+limg;

fimshowpair(targetImgs(:,:,:,1), (comp) );
title('recompose');

%% 
 
vinFname = '../data/new2/DSCN1213.MOV';
voutFname ='../res/our_comp.MOV';

vin=VideoReader( vinFname); 
vout=VideoWriter( voutFname, 'Uncompressed AVI' ); 

tirth.reconstrAll(vout,vin, rimg_ret ,calData , 0.25 );

fclose(vin);
fclose(vout);






