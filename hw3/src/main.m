%
%
%

root='../data';

im1=imread(fullfile(root,'venus.png'));
im2=imread(fullfile(root,'monalisa.png'));
im3=imread(fullfile(root,'mask.png'));


im1=imread(fullfile(root,'fg.jpg'));
im2=imread(fullfile(root,'bg.jpg'));
im3=imread(fullfile(root,'mask_our.png'));

F=lib.poisson(im1,im2,im3);

fimshowpair(im2,F);

%% small test

m=1:12;
m=reshape(m,3,[])';
h=3;
disp(m)
%circshift(m,[0,1])
%circshift(m,[1,0])

% n-th element specifies the shift 
% amount for the n-th dimension
% of array A.
circshift(m,[0,2])

%% 

im1=imread(fullfile(root,'im1_32.png'));
im2=imread(fullfile(root,'im2_32.png'));
im3=imread(fullfile(root,'mask_32.png'));

F=lib.my_poisson(im1,im2,im3);

fimshowpair(im1,im2);
fimshowpair(im3,F);

%%
 
% fg,bg,mask
F=lib.my_poisson(im1,im2,im3);

fimshowpair(im2,F);

%% 

vinPath=fullfile(root,'IMG_2027.MOV');
vin=VideoReader(vinPath);

voutPath = fullfile(root,'cup_s.avi');
video_resize(vinPath,voutPath, 480/1080);

%%

vin=VideoReader(voutPath);
num = vin.NumberOfFrames;

fid=round(num*0.5);
aframe =uint8(read(vin, fid)); 

af=flipdim(aframe,1);
af=flipdim(af,2);

fimshow(af); 

%%  
%
% 

fg=imread('../data/cup_fg.png');
bk=imread('../data/cup.png');
mask=imread('../data/cup_mask.png');
mask=mask(:,:,1);
mask=~mask;
F=lib.my_poisson(fg,bk,mask);
fimshow(F);


%%

vpath = '../data/ccc/campus.avi';
voutPath ='../data/ccc/tout_ori.avi';

fg = imread('../data/ccc/fg_2.png');
mask= imread('../data/ccc/mask3.png');
mask=mask(:,:,1);

fgflag = find(mask > 0);

vinObj = VideoReader(vpath);
voutObj = VideoWriter(voutPath);
voutObj.open();
num=vinObj.NumberOfFrames;
presol=[];
for k=1:vinObj.NumberOfFrames
    bk=vinObj.read(k);
    
    F=lib.my_poisson(fg,bk,mask);
    presol=F;
    F(F>1)=1;
    F(F<0)=0; 
    writeVideo(voutObj, F); 
    fprintf('proc %d/%d\n',k,num);
end
voutObj.close();
disp('done');












