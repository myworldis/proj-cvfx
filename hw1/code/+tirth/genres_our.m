% test data

imgs={};
imgs{end+1}=imread('../data/new2/DSCN1208.JPG');
imgs{end+1}=imread('../data/new2/DSCN1209.JPG');
imgs{end+1}=imread('../data/new2/DSCN1210.JPG');
imgs{end+1}=imread('../data/new2/DSCN1211.JPG');
imgs{end+1}=imread('../data/new2/DSCN1212.JPG');

disp('load done');
%%

imgs={};
imgs{end+1}=imread('../data/testset/A1.jpg');
imgs{end+1}=imread('../data/testset/A2.jpg');
imgs{end+1}=imread('../data/testset/A3.jpg');
imgs{end+1}=imread('../data/testset/A4.jpg');
imgs{end+1}=imread('../data/testset/A5.jpg');
imgs{end+1}=imread('../data/testset/A6.jpg');
imgs{end+1}=imread('../data/testset/A7.jpg');
imgs{end+1}=imread('../data/testset/A8.jpg');
imgs{end+1}=imread('../data/testset/A9.jpg');

disp('load done');



%%

ratio = 0.35;

smImgs=zeros(size(imgs{1},1)*ratio,size(imgs{2},2)*ratio,3,0);

for k=1:numel(imgs)
    
    aim = ( double(imresize(imgs{k},ratio))./255 );
    smImgs(:,:,:,end+1)=aim;
end

disp('done');
 

%% vis 
figure
for k=1:numel(csmImgs)
    imshow(csmImgs(:,:,:,k));
    pause;
end

%%

targetImgs_2 = smImgs;

%%


fprintf('# of frames = %d \n', size(targetImgs_2,4));
 
[rimg , limg ,calData]=tirth.rgbWeiss(targetImgs_2);

%%
fimshow(tirth.normalize(rimg));
title('reflectance');

fimshow(tirth.normalize(limg));
title('light of frame 1');
 

%% save

imwrite(rimg, '../data/rimg_our.png');
  
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

fimshowpair(targetImgs_zb(:,:,:,1), (comp) );
title('recompose');

%% 
 
vinFname = '../data/new2/DSCN1213.MOV';
voutFname ='../res/our_comp.MOV';

vin=VideoReader( vinFname); 
vout=VideoWriter( voutFname, 'Uncompressed AVI' );


tirth.reconstrAll(vout,vin, rimg_ret ,calData , 0.35 );

fclose(vin);
fclose(vout);






