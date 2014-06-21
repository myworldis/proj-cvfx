%
%
%
% 

VIN_PATH =fullfile(gdef.dataroot,'our','DSCN1671s.avi');

V_IMG_DIR = fullfile(gdef.dataroot , 'our','1671s_img');
mkdir_if(V_IMG_DIR);

%%

% SVAE
% 620 - 1440

vin = tirth.VideoProxy();
vin.load(VIN_PATH);

for k=1:5:vin.totalFrame()
    
    f=vin.getFrame(k);
    
    imwrite(f,fullfile(V_IMG_DIR,sprintf('f_%d.ppm',k)) );
   
    
end
disp('done');


%% load frame and camera matrix


pts3d_FPath = fullfile(gdef.dataroot,'our\1671s_img\dense_fix\v1.0_pts.txt') ;

IMG_DIR = fullfile(gdef.dataroot,'our','1671s_img');
CAM_DIR =fullfile(gdef.dataroot,'our','1671s_img\dense_fix\v1.nvm.cmvs\00\txt');
CAM_VIS_DIR =fullfile(gdef.dataroot, 'our','1671s_img\dense_fix\v1.nvm.cmvs\00\visualize');

 
%%

% fix f
ff=[933.82232666,640,933.82232666,360,0];

 

%% load first frame

clear cK ck exttx R t cR CK44 ck44 P p pmat

fid=allidx(1);
img_f = imread( fullfile( IMG_DIR ,sprintf('f_%d.ppm',fid) ) );
 
size(img_f);

fix_k=[
933.82232666 0 640 
0 933.82232666 360 
0 0 1  
];

[cK , exttx , R , t ]=tirth.excamera_fix(allcam{fid},fix_k);


tirth.printM(fix_k);

%% resave f1

imwrite(img_f,'f1.png');

%% p3d
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
  
%% reconstruct room and object
 
room_mask = imread(fullfile(gdef.dataroot,'our/room.png'));
 
fimshowpair(room_mask,tirth.normalize(depth_map),'blend');

room_mask=sum(room_mask,3);
room_map=bwlabel(room_mask>10);
 

%% extract seg valid mask
 
pts2d = rep2d;
pts2d_img_ind = rep2d_ind;

imsize=size(room_map);

% plane mask
pl_flag={};
pl_mask={};
for i=1:max2(room_map)
    if nnz(room_map==i) > 30
        pl_mask{end+1}=room_map==i;
        pl_flag{end+1}=tirth.extract_valid_mask(room_map==i,pts2d,imsize);
        fprintf('pl %d got %d pts\n',i,nnz(pl_flag{end}));
    end
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


%% floor refit
floor_pts=plpts_g{1};
[FRes,inliers]=toolkit_g6_me.myRANSACFitPlane(floor_pts');

floor_model=FRes.Theta;
fl_axis = floor_model(1:3);
fl_axis = fl_axis ./ norm(fl_axis);


figure;
dpts=pts3d;
dpts(:,2)=-1*dpts(:,2);
showPointCloud_gui(dpts,dpts(:,3));
dfpts=floor_pts;
dfpts(:,2)=-1*dfpts(:,2);
showPointCloud_gui(dfpts,dfpts(:,3));

disp('all done');
%% reproject  

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

%% extract plane vex

fimshow(refit_depth);
w1 = [
   590,414;
   556,452;
   711,483;
   737,441
];

w2 = [
    588,124;
    596,351;
    734,366;
    739,142
];
 
allw = {w1,w2};

cK44 = eye(4);
cK44(1:3,1:3)=cK;
cam = cK44 * exttx;
invcam = inv(cam);


ext_ratio =0;

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

%% PY plane

for k=1:numel(all_wvex3d)
    
    objName = sprintf('wall_%d',k);
    tirth.gen_wall_mesh(all_wvex3d{k},objName);
    fprintf('\n\n');
end

%%


