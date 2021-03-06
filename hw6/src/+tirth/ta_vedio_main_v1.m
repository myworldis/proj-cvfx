%
%
% try to use fix cK
%


%% load frame and camera matrix

IMG_DIR =fullfile(gdef.dataroot,'video','0834','IMG');
CAM_DIR =fullfile(gdef.dataroot,'video','0834','dense\v1fix.nvm.cmvs\00\txt');
CAM_VIS_DIR =fullfile(gdef.dataroot,'video','0834','dense\v1fix.nvm.cmvs\00\visualize');

pts3d_FPath = fullfile(gdef.dataroot,'video','0834','dense','pts_obj.txt') ;
 
%% load first frame

fid=allidx(1);
img_f = imread( fullfile( IMG_DIR ,sprintf('f_%d.ppm',fid-1) ) );


fixK=[
893.533447266 0 427 
0 893.533447266 240 
0 0 1  
];

[cK , exttx , R , t ]=tirth.excamera_fix(allcam{fid},fixK);
 

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
    all_rep2d=[];
    all_rep2d(:,1) = rep2d_h(:,1) ./ rep2d_h(:,3); 
    all_rep2d(:,2) = rep2d_h(:,2) ./ rep2d_h(:,3); 
else 
    pts4d = [pts3d,ones(size(pts3d,1),1) ];
    rep2d_h =( cK*exttx(1:3,:)*pts4d')';
    all_rep2d=[];
    all_rep2d(:,1) = rep2d_h(:,1) ./ rep2d_h(:,3); 
    all_rep2d(:,2) = rep2d_h(:,2) ./ rep2d_h(:,3); 
end

rep2d=[];
rep2d_ind=[];


PW=size(img_f,2);
PH=size(img_f,1);
depth_map=zeros(PH,PW);

eff_2d_idx=false(size(all_rep2d,1),1);

for k=1:size(all_rep2d,1)
    
    xy=round([all_rep2d(k,1),all_rep2d(k,2)]); 

    if xy(1) > 0 && xy(1) < PW && xy(2) > 0 && xy(2) < PH 
       % valid point
       xx=xy(1);
       yy=xy(2);
       
       depth_map(yy,xx)=pts3d(k,3);
       
       % DONT round it
       rep2d=cat(1,rep2d,all_rep2d(k,:));
       rep2d_ind(end+1)=sub2ind([PH,PW],yy,xx);
       
       eff_2d_idx(k)=true;
    else
       eff_2d_idx(k)=false;
    end    
end
 
fimshowpair(tirth.normalize(depth_map),img_f,'blend');
fimshow( depth_map );

% align rep2d pts index
eff_pts3d=pts3d(eff_2d_idx,:);
 
%% debug mesh

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

%% debug mesh

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

%% compose debug video
if 0
vin =fullfile(gdef.dataroot,'video','IMG_0834_480.avi');
res_vin =fullfile(gdef.dataroot,'res_pre.avi');

ori=tirth.VideoProxy();
ori.load(vin);

res=tirth.VideoProxy();
res.load(res_vin);

total=min(ori.totalFrame , res.totalFrame );

vout = VideoWriter('vout.avi');
vout.open();

for k=1:total
    
    fres = res.getFrame(k);
    ores = ori.getFrame(k);
    
    comp=fres*0.5+ores*0.5;
    vout.writeVideo(uint8(comp));
end

vout.close();

disp('all done');
end
%% handle 3d reconstruction

vin =fullfile(gdef.dataroot,'video','IMG_0834_480.avi');

ori=tirth.VideoProxy();
ori.load(vin);

f1 = ori.getFrame(1);

imwrite(f1,'f1.png');

%% reconstruct room and object

obj_mask = imread(fullfile(gdef.dataroot,'f1_obj.png'));
room_mask = imread(fullfile(gdef.dataroot,'fl_room.png'));

fimshowpair(obj_mask,tirth.normalize(depth_map),'blend');
fimshowpair(room_mask,tirth.normalize(depth_map),'blend');

obj_mask=sum(obj_mask,3);
room_mask=sum(room_mask,3);

room_map=bwlabel(room_mask>10);
obj_map=bwlabel(obj_mask>10);

%% extract seg valid mask
 
pts2d = rep2d;
pts2d_img_ind = rep2d_ind;

imsize=size(obj_mask);

% plane mask
pl_flag={};
pl_mask={};
for i=1:max2(room_map)
    pl_mask{i}=room_map==i;
    pl_flag{i}=tirth.extract_valid_mask(room_map==i,pts2d,imsize);
    fprintf('pl %d got %d pts\n',i,nnz(pl_flag{i}));
end

% object
obj_mask={};
obj_flag={};

for i=1:max2(obj_map)
    obj_mask{i}=obj_map;
    obj_flag{i}=tirth.extract_valid_mask(obj_map==i,pts2d,imsize);
    
    fprintf('obj %d got %d pts\n',i,nnz(obj_flag{i}));
end

%% [ROOM] fit plane and re-estimate DEPTH

refit_depth=zeros(size(depth_map));

plpts_g={};
plane_model={};

figure(3);clf;
showPointCloud_gui(pts3d,pts3d(:,3));

for k=1:numel(pl_flag) 
    pl_pts3d=eff_pts3d(pl_flag{k},:);
    [refit_depth,plpts_g{k}]=tirth.refit_plane(pl_pts3d,pl_mask{k},cK,exttx,refit_depth);    
    
    [FRes,inlflag]=toolkit_g6_me.myRANSACFitPlane(plpts_g{k}');
    plane_model{k}=FRes.Theta(:);
    
    if 1
       pp=plpts_g{k};
       showPointCloud_gui(pp(inlflag,:),pp(:,3));
       clear pp;
    end
    
end

disp('all done');
 
 %%
figure;
pp=pts3d;
pp(:,2)=-1*pp(:,2);
showPointCloud_gui(pp,pp(:,3));

pp=plpts_g{1};
pp(:,2)=-1*pp(:,2);
showPointCloud_gui(pp(inlflag,:),pp(:,3));

pp=plpts_g{3};
pp(:,2)=-1*pp(:,2);
showPointCloud_gui(pp(inlflag,:),pp(:,3));

%% floor refit
floor_pts=plpts_g{2};
[FRes,inliers]=toolkit_g6_me.myRANSACFitPlane(floor_pts');

floor_model=FRes.Theta;
fl_axis = floor_model(1:3);
fl_axis = fl_axis ./ norm(fl_axis);


%%
figure;
pp=pts3d;
pp(:,2)=-1*pp(:,2);
showPointCloud_gui(pp,pp(:,3));
pp=floor_pts;
pp(:,2)=-1*pp(:,2);
showPointCloud_gui(pp,pp(:,3));

disp('all done');

%% reproject  ??

ck44=eye(4);
ck44(1:3,1:3)=cK;

invcam = inv(ck44*exttx);
rep_pts3d=nan(size(refit_depth,1),size(refit_depth,2),3);

for i=1:size(refit_depth,1)
    for j=1:size(refit_depth,2)
        
        zval = refit_depth(i,j);
        
        if zval ~=0
           
            p3=tirth.myim2world(j,i,zval,invcam); 
            rep_pts3d(i,j,:)=p3;
            
        end
    end
end
disp('rep_pts3d done'); 


%% fit boxes


theta=acos( dot([0,-1,0],fl_axis) );

fr_axis = cross( [0,-1,0] , fl_axis );
fr_mat = createRotation3dLineAngle([0,0,0,fr_axis(:)'],theta);

fr_mat = fr_mat(1:3,1:3);
fr_mat = fr_mat';

all_obb={};
for k=1:numel(obj_flag)
     
    obj_pts3d=eff_pts3d(obj_flag{k},:);
     
    
    if k~=2 
        all_obb{k}=tirth.exbox(obj_pts3d,fl_axis,plane_model);
        
    else
        obj_pts3d =(fr_mat * obj_pts3d')';
        
        % knn filtering 

        % k-by-N
        dist=pdist2(obj_pts3d,obj_pts3d,'euclidean','Smallest',10);

        % n-k
        mdist=mean(dist',2);
        th_dist=median(mdist);

        goodFlag2 = mdist < th_dist;
        obj_pts3d=obj_pts3d(goodFlag2,:);
        
        all_obb{k} = getBBoxByPts3(obj_pts3d);
        all_obb{k} =(inv(fr_mat)*all_obb{k}')'; 
    end 
end

disp('fit boxes done');

%% enforce on floor


% floor fr mat
rigi_yaxis = [0,-1,0];

fl_axis= floor_model(1:3);
fl_axis=fl_axis./norm(fl_axis);

theta=acos( dot(rigi_yaxis,fl_axis) );
fr_axis = cross(rigi_yaxis , fl_axis );
fr_mat = createRotation3dLineAngle([0,0,0,fr_axis(:)'],theta);
fr_mat = fr_mat(1:3,1:3);
fr_mat = fr_mat';

fr_mat44 = eye(4);
fr_mat44(1:3,1:3)=fr_mat;
fix_fl_model = floor_model(:)'*inv(fr_mat44);

fix_fl_model = fix_fl_model ./ norm(fix_fl_model(1:3));

for k=1:numel(all_obb)
    
    obb_k = all_obb{k};
     
    derr = pointPlaneDist(obb_k,floor_model);
    
    % take min 4
    [sval,sidx]=sort(derr,'ascend');
    
    % enforce on plane
    cl_vex = obb_k(sidx(1:4),:);
    
    % re-rot
    % Nx4
    cl_vex_fr = (fr_mat*cl_vex')';
    % 4xN
    cl_vex_fr = cl_vex_fr';
    
    L = [ fix_fl_model(:)'; 
          [1,0,0,0]
          [0,0,1,0]
          [0,0,0,1]
    ];
    
    b=zeros(4,size(cl_vex_fr,2));
    
    % b(1,:)=[ 0...]
      b(2,:)=cl_vex_fr(1,:);% x
      b(3,:)=cl_vex_fr(3,:);% z 
      b(4,:)=ones(1,size(cl_vex_fr,2));
      
    % 4xN
    sol = L \ b;
    sol = sol';
    sol = sol(:,1:3);
     
    sol_ori = (inv(fr_mat) * sol')';
    
    obb_k(sidx(1:4),:)=sol_ori;
     
    all_obb{k}=obb_k;
    
    %clear sol b L cl_vex_fr
end
 
disp('geo refine done');

%% show all boxes

figure;

dp=pts3d;
dp(:,2)=-1*dp(:,2);

showPointCloud_gui(dp,dp(:,3));
for k=1:numel(all_obb)
    if ~isempty(all_obb{k})
        box=all_obb{k};
        box(:,2)=-1*box(:,2);
        showBBox3D(box);
    end
end

%% extract plane vex

fimshow(refit_depth);
w1 = [
    477,160;
    634,263;
    653,170;
    490,80;    
];

w2 = [
    375,157;
    383,7;
    458,10;
    448,152;
];

w3 = [
    400,195;
    537,299;
    615,282;
    461,182;
];

allw = {w1,w2,w3};

cK44 = eye(4);
cK44(1:3,1:3)=cK;
cam = cK44 * exttx;
invcam = inv(cam);


ext_ratio =80;

refit_depthmap=refit_depth;

all_wvex3d={};
for iw=1:numel(allw)
   
    vex=allw{iw};
    theta=plane_model{iw};
    
    vex_3d = [];
    
    for k=1:size(vex,1)
        wpts=vex(k,:);
        dep = refit_depthmap(wpts(2),wpts(1));
        assert(dep~=0,'depth is zeros**');
        
        %%xyz_im = [wpts(1)*dep , wpts(2)*dep , dep ,1];
        %xyz_im = [wpts(1) , wpts(2) , dep ,1];
           
        %pts3d_xyzw=(invcam*xyz_im')';
        %pts3d_xyzw=pts3d_xyzw./pts3d_xyzw(4);
        
        
        p0 = rep_pts3d(wpts(2),wpts(1),:);
        
        vex_3d=cat(1,vex_3d, p0(:)' );
        clear p0
    end
    
    %% enlarge plane
    if 1
        c0 = mean(vex_3d);
 
        for iv=1:size(vex_3d,1)
           dir = vex_3d(iv,:) - c0 ;
           dir_nv = dir ./ norm(dir);

           vext = c0 + dir + dir_nv*ext_ratio;
           vex_3d(iv,:)=vext;
        end
    
    end
    
    % print
    all_wvex3d{iw}=vex_3d; 
end


% debug vex
if 1
    
    figure;
    showPointCloud_gui(pts3d,pts3d(:,3),'regularAxisOrder',true);
    
    for k=1:numel(all_wvex3d)
        pp=all_wvex3d{k};
        
        hold on;
        %plot3(pp(:,1),pp(:,2),pp(:,3),'+','markersize',12,'linewidth',2);
        plot3(pp(:,1),pp(:,2),pp(:,3),'linewidth',2);

        c0=mean(pp);
        hold on;
        plot3(c0(:,1),c0(:,2),c0(:,3),'x','markersize',12,'linewidth',2);
    end
end


%% PY box

for k=1:numel(all_obb)
    
    objName = sprintf('box_%d',k);
    tirth.gen_box_mesh(all_obb{k},objName);
    fprintf('\n\n');
end

%% PY plane

for k=1:numel(all_wvex3d)
    
    objName = sprintf('wall_%d',k);
    tirth.gen_wall_mesh(all_wvex3d{k},objName);
    fprintf('\n\n');
end

 
%%

res_pre = imread( fullfile(gdef.dataroot,'render.png'));

fimshowpair(img_f,res_pre,'blend')




