%
% test lab video 1
%
% :IMG_0834_480_frame
% 


% load reconstructed point cloud

pts3d_FPath = fullfile(gdef.dataroot,'IMG_2082_480_frames','dense','01.0.obj__.txt') ;

tfile = fopen(pts3d_FPath);

data = textscan(tfile,'%s %f %f %f');

pts3d = [data{2},data{3},data{4}];

%% load frame by frame data
 

img_f1 = imread( fullfile(gdef.dataroot,'IMG_2082_480_frames','f_1.ppm') );
 

camera_f1 = [
    962.378055089  180.630879391 -557.871311545     -149.118629654 
    -217.642995503 1145.39470449 -188.290538363     27.1279809709 
    0.511591862528 0.574971668201   0.638501583149   0.0890433788429    
];


%%
[R,Q,Qx,Qy,Qz] =cv.RQDecomp3x3(camera_f1(1:3,1:3));

tx=camera_f1(:,4);

cK=R;
cR=Q;
ct=inv(Q)*inv(cK)*tx;

disp(camera_f1);
disp(cK*[cR , cR*ct ]);

% k[R|t] = 

ins_tx = [cK,[0,0,0]'];
ext_tx = [cR,cR*ct];
ext_tx = cat(1,ext_tx,[0,0,0,1]);

%% update point cloud

pts4d = [pts3d,ones(size(pts3d,1),1) ];

wpts4d=(ext_tx*pts4d')';
wpts4d(:,1)=wpts4d(:,1)./wpts4d(:,4);
wpts4d(:,2)=wpts4d(:,2)./wpts4d(:,4);

pts3d_w = wpts4d(:,1:3);
pts4d_w = wpts4d;

%% show 2d mapping 

figure;
showPointCloud_gui(pts3d_w,pts3d_w(:,1));
 

rep2d_h =(ins_tx * pts4d_w')';
rep2d=[];
rep2d(:,1) = rep2d_h(:,1)  ./ rep2d_h(:,3); 
rep2d(:,2) = rep2d_h(:,2)  ./ rep2d_h(:,3); 

PW=480;
PH=854;
depth_map=zeros(PH,PW);

for k=1:size(rep2d,1)
    
    xy=round([rep2d(k,1),rep2d(k,2)]); 
    if xy(1) > 0 && xy(1) < PW && xy(2) > 0 && xy(2) < PH 
       % valid point
       xx=xy(1);
       yy=xy(2);
       depth_map(yy,xx)=rep2d_h(k,3);
              
    end    
end 
fimshowpair(tirth.normalize(depth_map),img_f1,'blend');
fimshowpair(tirth.normalize(depth_map),img_f1);
fimshow(tirth.normalize(depth_map));
disp('done');

%% extract floor mask
 
img_sum = sum(img_f1,3);

fl_mask = img_sum > 200*3-10;

eff_flag = false(size(rep2d,1));
for k=1:size(rep2d,1)    
    xy=round([rep2d(k,1),rep2d(k,2)]); 
    if xy(1) > 0 && xy(1) < PW && xy(2) > 0 && xy(2) < PH 
       % valid point
       xx=xy(1);
       yy=xy(2);
       if fl_mask(yy,xx) 
          eff_flag(k)=true;
       end
    end    
end 

disp('done');

%% [TASK] fit plane 
pl_pts=pts3d_w(eff_flag,:);
[FRes,inliers]=toolkit_g6_me.myRANSACFitPlane(pl_pts');

figure;
showPointCloud_gui(pl_pts(FRes.CS,:),pl_pts(FRes.CS,1));
 
%% re-estimate depth
 
fl_mask1d_eff=find(reshape(fl_mask,[],3));

Pmat=[ ins_tx(1,:);
       ins_tx(2,:);
       FRes.Theta';
       [0,0,0,1] ]; 
 
fx = ins_tx(1,1);
fy = ins_tx(2,2);
u = ins_tx(1,3);
v = ins_tx(2,3);
abc=FRes.Theta(1:3)';
d=FRes.Theta(4);

reg_depth = depth_map;
plane_3dh = [];

for k=1:numel(fl_mask1d_eff)
    
    ii=fl_mask1d_eff(k);
    
    [yy,xx]=ind2sub(size(fl_mask),ii);

    Pmat=[ fx,0,u-xx
           0 ,fy,v-yy
           abc
    ]; 

    p3d=mldivide(Pmat,[0,0,-d]');
    plane_3dh=cat(1,plane_3dh,p3d(:)');
    
    reg_depth(yy,xx)=p3d(3);
     
end
 

debug_pts = pl_pts;
debug_pts = cat(1,debug_pts,plane_3dh(:,1:3)); 
debug_pts(:,2)=-debug_pts(:,2);

figure;
showPointCloud_gui(debug_pts,debug_pts(:,3));


%%


figure;
showPointCloud_gui(plane_3dh(:,1:3),plane_3dh(:,3));
