%
% test video 2
% 
 
% :IMG_0834_480_frame
% 


%% load frame and camera matrix

IMG_DIR =fullfile(gdef.dataroot,'video','IMG_0834_480_frame');
CAM_DIR =fullfile(gdef.dataroot,'video','IMG_0834_480_frame','dense\v1.nvm.cmvs\00\txt');
CAM_VIS_DIR =fullfile(gdef.dataroot,'video','IMG_0834_480_frame','dense\v1.nvm.cmvs\00\visualize');


fid=1;

img_f = imread( fullfile( IMG_DIR ,sprintf('f_%d.ppm',fid) ) );
img_fvis = imread( fullfile( CAM_VIS_DIR ,sprintf('%.8d.jpg',fid) ) );
cam_f_fpath = fullfile( CAM_DIR , sprintf('%.8d.txt',fid-1) );

fin=fopen(cam_f_fpath,'r');

ss=fgets(fin);

cam_mat=fscanf(fin,'%f',[4,3]);
cam_mat=cam_mat';
fclose(fin);

fimshowpair(img_f,img_fvis,'diff');

%% load reconstructed point cloud

pts3d_FPath = fullfile(gdef.dataroot,'video','IMG_0834_480_frame','dense','pts_obj.txt') ;

tfile = fopen(pts3d_FPath);

data = textscan(tfile,'%s %f %f %f');

pts3d = [data{2},data{3},data{4}];

rmRt=0;

if rmRt
    pts4d = [pts3d,ones(size(pts3d,1),1) ];
    % remove [R|Rt]
    pts4d = (exttx*pts4d')';

    pts4d(:,1)=pts4d(:,1)./pts4d(:,4);
    pts4d(:,2)=pts4d(:,2)./pts4d(:,4);
    pts4d(:,3)=pts4d(:,3)./pts4d(:,4);
    pts3d=pts4d(:,1:3);
    clear pts4d;
    
    disp('rm R|Rt');
end

%%
figure;
dpts3d=pts3d; 
dpts3d(:,2)=dpts3d(:,2)*-1;
showPointCloud_gui(dpts3d,dpts3d(:,1));

hold on;
cood=[
1,0,0;
-1,0,0;
0,1,0;
0,-1,0;
0,0,1;
0,0,-1;
]*0.2;
plot3(cood(:,1),cood(:,2),cood(:,3),'linewidth',3);

%% re-mapping known points

if rmRt
    rep2d_h =(cK * pts3d')';
else
    pts4d = [pts3d,ones(size(pts3d,1),1) ];
    rep2d_h =(cam_mat * pts4d')';
end

rep2d=[];
rep2d(:,1) = rep2d_h(:,1) ./ rep2d_h(:,3); 
rep2d(:,2) = rep2d_h(:,2) ./ rep2d_h(:,3); 

rep2d_ind=[];


PW=size(img_fvis,2);
PH=size(img_fvis,1);
depth_map=zeros(PH,PW);

for k=1:size(rep2d,1)
    
    xy=round([rep2d(k,1),rep2d(k,2)]); 
    if xy(1) > 0 && xy(1) < PW && xy(2) > 0 && xy(2) < PH 
       % valid point
       xx=xy(1);
       yy=xy(2);
       depth_map(yy,xx)=rep2d_h(k,3);
       
       rep2d_ind(k)=sub2ind([PH,PW],yy,xx);
    end    
end
 
%fimshowpair(tirth.normalize(depth_map),img_fvis,'blend');
fimshowpair(tirth.normalize(depth_map),img_f,'blend');

fimshow(tirth.normalize(depth_map));
 

%%

p0=[457,176];
p1=[620,293];
p2=[530,307];
p3=[383,196];

p0_idx=sub2ind([PH,PW],p0(2),p0(1));
p1_idx=sub2ind([PH,PW],p1(2),p1(1));
p2_idx=sub2ind([PH,PW],p2(2),p2(1));
p3_idx=sub2ind([PH,PW],p3(2),p3(1));

p0_pts = pts3d(p0_idx==rep2d_ind,:);
p1_pts = pts3d(p1_idx==rep2d_ind,:);
p2_pts = pts3d(p2_idx==rep2d_ind,:);
p3_pts = pts3d(p3_idx==rep2d_ind,:);

 
figure;
dpts3d=pts3d;  
showPointCloud_gui(dpts3d,dpts3d(:,1),'regularAxisOrder',true);

allpts=[p0_pts;p1_pts;p1_pts;p2_pts;p2_pts;p3_pts];
hold on;
plot3(allpts(:,1),allpts(:,2),allpts(:,3),'linewidth',3);

%% mesh 2


p0=[171,225];
p1=[177,308];
p2=[225,291];
p3=[231,229];

p0_idx=sub2ind([PH,PW],p0(2),p0(1));
p1_idx=sub2ind([PH,PW],p1(2),p1(1));
p2_idx=sub2ind([PH,PW],p2(2),p2(1));
p3_idx=sub2ind([PH,PW],p3(2),p3(1));

p0_pts = pts3d(p0_idx==rep2d_ind,:);
p1_pts = pts3d(p1_idx==rep2d_ind,:);
p2_pts = pts3d(p2_idx==rep2d_ind,:);
p3_pts = pts3d(p3_idx==rep2d_ind,:);


allpts2=[p0_pts;p1_pts;p1_pts;p2_pts;p2_pts;p3_pts];
hold on;
plot3(allpts2(:,1),allpts2(:,2),allpts2(:,3),'linewidth',3);

%% mesh 3

p0=[171,225];
p1=[231,229];
p2=[197,205];
p3=[163,213];


p0_idx=sub2ind([PH,PW],p0(2),p0(1));
p1_idx=sub2ind([PH,PW],p1(2),p1(1));
p2_idx=sub2ind([PH,PW],p2(2),p2(1));
p3_idx=sub2ind([PH,PW],p3(2),p3(1));

p0_pts = pts3d(p0_idx==rep2d_ind,:);
p1_pts = pts3d(p1_idx==rep2d_ind,:);
p2_pts = pts3d(p2_idx==rep2d_ind,:);
p3_pts = pts3d(p3_idx==rep2d_ind,:);


allpts3=[p0_pts;p1_pts;p1_pts;p2_pts;p2_pts;p3_pts];
hold on;
plot3(allpts3(:,1),allpts3(:,2),allpts3(:,3),'linewidth',3);
%%

p0=[31,227];
p1=[393,160];
p2=[401,47];
p3=[103,165];
p0_idx=sub2ind([PH,PW],p0(2),p0(1));
p1_idx=sub2ind([PH,PW],p1(2),p1(1));
p2_idx=sub2ind([PH,PW],p2(2),p2(1));
p3_idx=sub2ind([PH,PW],p3(2),p3(1));

p0_pts = pts3d(p0_idx==rep2d_ind,:);
p1_pts = pts3d(p1_idx==rep2d_ind,:);
p2_pts = pts3d(p2_idx==rep2d_ind,:);
p3_pts = pts3d(p3_idx==rep2d_ind,:);


allpts4=[p0_pts;p1_pts;p1_pts;p2_pts;p2_pts;p3_pts];
hold on;
plot3(allpts4(:,1),allpts4(:,2),allpts4(:,3),'linewidth',3);


%%

allpts
allpts2
allpts3
allpts4


%% extract  camera

[cK , exttx , R, t ]=tirth.excamera(cam_mat);

z_rotpi = createRotationOz(pi)

I=eye(4);

IR=I;
IR(1:3,1:3)=I(1:3,1:3)*R;

inv_xz=eye(4);
inv_xz(3,3)=-1;
inv_xz(1,1)=-1;

cam_tx=eye(4);
cam_tx(1:3,4)=t;

final_tx=z_rotpi*inv_xz;


for k=1:size(final_tx,1)
   
   fprintf('%s,\n',strjoin(strsplit(mat2str(exttx(k,:))),',')); 
end


%%

p4=cat(2,allpts,ones(size(allpts,1),1));

p4h=(cam_mat*p4')';

imp=[];
for k=1:2
    imp(:,k)=p4h(:,k)./p4h(:,3);
end
fimshow(img_f);hold on;
plot(imp(:,1),imp(:,2),'+');



%% handle camera setup

%yrot=createRotationOy(pi) 


mirxz=eye(4);
mirxz(1,1)=-1; 
mirxz(3,3)=-1;

cam_tx=inv(exttx);



disp('yrot+mirx');
tirth.printM(cam_tx);

%% keep obj sync
  

mirx=eye(4);
mirx(1,1)=-1; 
mirx(3,3)=-1; 

objtx=inv(exttx);

disp('objtx');
tirth.printM(objtx);


%% for real rendering
% 

% calibration -Z, top-left 0,0
% 

% blender +Z , bot-left 0,0
% 

p4=cat(2,allpts,ones(size(allpts,1),1));


tx=inv(cam_mat2world);

ck4d=eye(4);
ck4d(1:3,1:3)=cK;

p4h2=(ck4d*tx*p4')';


imp2=[];
for k=1:2
    imp2(:,k)=p4h2(:,k)./p4h2(:,3);
end
imp2

%%


invY = eye(3);
invY(2,2)=-1;
invY(2,3)=PH;

invY*cK


%%

close all;

rim=imread('D:\nthu_school\CVFX\proj-cvfx\hw6\bpy\rayvis_blender\res\render.png');

fimshowpair(rim,img_f,'blend');
hold on;
plot(imp(:,1),imp(:,2),'+');



