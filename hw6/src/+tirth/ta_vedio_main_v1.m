%
%
% try to use fix cK
%


%% load frame and camera matrix

IMG_DIR =fullfile(gdef.dataroot,'video','0834','IMG');
CAM_DIR =fullfile(gdef.dataroot,'video','0834','dense\v1fix.nvm.cmvs\00\txt');
CAM_VIS_DIR =fullfile(gdef.dataroot,'video','0834','dense\v1fix.nvm.cmvs\00\visualize');

pts3d_FPath = fullfile(gdef.dataroot,'video','0834','dense','pts_obj.txt') ;

% ********************
% re-parsing MAPPING file
%
% ********************

fid=1;

img_f = imread( fullfile( IMG_DIR ,sprintf('f_%d.ppm',fid-1) ) );
campath = fullfile( CAM_DIR , sprintf('%.8d.txt',fid-1) );

fin=fopen(campath,'r');

ss=fgets(fin);

cam_mat=fscanf(fin,'%f',[4,3]);
cam_mat=cam_mat';
fclose(fin);

%% fix K

fixK=[
893.533447266 0 427 
0 893.533447266 240 
0 0 1  
];

tirth.printM(fixK);

%% load all camera txt

clist = my_module.gt_tool.getPathList(CAM_DIR,'.txt');
 

allcam={};
allidx=[];

for k=1:numel(clist)
    
campath=fullfile(CAM_DIR,clist{k});

[~,fn,ext]=fileparts(clist{k});

fin=fopen(campath,'r');

ss=fgets(fin);

cam_mat=fscanf(fin,'%f',[4,3]);
fclose(fin);

allcam{end+1}=cam_mat';
allidx(end+1)=str2num(fn);
 
end


tx_xz=eye(3);
tx_xz(1,1)=-1;
tx_xz(3,3)=-1;


% extract R and t and save
for k=1:numel(allcam)    
    [cK , exttx , R , t ]=tirth.excamera_fix(allcam{k},fix_k);
end

disp('done');

%%


% load 1st
[cK , exttx , R , t ]=tirth.excamera_fix(allcam{1},fix_k);


% camera

fix_coord=eye(4);
fix_coord(1,1)=1;
fix_coord(2,2)=-1;
fix_coord(3,3)=-1;
  
final_Rt =  (exttx); 

%  The first three elements specify the rotation axis, and the last element defines the angle of rotation.
axisAngle = vrrotmat2vec(final_Rt(1:3,1:3));
rAxis=axisAngle(1:3);
rangle=axisAngle(4);

tirth.printM(final_Rt);

tirth.printM([rangle,rAxis]);

%% load reconstructed point cloud


tfile = fopen(pts3d_FPath);

data = textscan(tfile,'%s %f %f %f');

pts3d = [data{2},data{3},data{4}];




% remove [R|Rt]
removeRRt=0;
if removeRRt
    pts4d = [pts3d,ones(size(pts3d,1),1) ];
    pts4d = (exttx*pts4d')';

    pts4d(:,1)=pts4d(:,1)./pts4d(:,4);
    pts4d(:,2)=pts4d(:,2)./pts4d(:,4);
    pts4d(:,3)=pts4d(:,3)./pts4d(:,4);
    pts3d=pts4d(:,1:3);

    clear pts4d; 
    disp('remove [R|Rt]');
else
    %disp('[R|Rt]');
    %tirth.printM((exttx));
end

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

if removeRRt
    rep2d_h =( cK * pts3d')';
    rep2d=[];
    rep2d(:,1) = rep2d_h(:,1) ./ rep2d_h(:,3); 
    rep2d(:,2) = rep2d_h(:,2) ./ rep2d_h(:,3); 
else
    
    pts4d = [pts3d,ones(size(pts3d,1),1) ];
    rep2d_h =( cK*exttx(1:3,:)*pts4d')';
    rep2d=[];
    rep2d(:,1) = rep2d_h(:,1) ./ rep2d_h(:,3); 
    rep2d(:,2) = rep2d_h(:,2) ./ rep2d_h(:,3); 
end
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

fimshow( depth_map );
 
%%

p0=[679,126];
p1=[642,229];
p2=[434,133];
p3=[448,61];

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

allpts=[p0_pts;p1_pts;p1_pts;p2_pts;p2_pts;p3_pts;p3_pts;p0_pts];
hold on;
plot3(allpts(:,1),allpts(:,2),allpts(:,3),'linewidth',3);


m1=[p0_pts;p1_pts;p2_pts;p3_pts];
    
m1_re=m1;

tirth.printM(m1(:,1:3));

%%

if removeRRt
    m1_img=(cK*m1_re(:,1:3)')';
    m1_img(:,1)=m1_img(:,1)./m1_img(:,3);
    m1_img(:,2)=m1_img(:,2)./m1_img(:,3);
else
    m1_re4 = cat(2,m1_re,ones(size(m1_re,1),1));
    
    m1_img=(cK*exttx(1:3,:)*m1_re4')';
    m1_img(:,1)=m1_img(:,1)./m1_img(:,3);
    m1_img(:,2)=m1_img(:,2)./m1_img(:,3);
end

close all;

rim=imread('D:\nthu_school\CVFX\proj-cvfx\hw6\bpy\rayvis_blender\res\render.png');

fimshowpair(rim,img_f,'blend');
hold on;
plot(m1_img(:,1),m1_img(:,2),'+');











