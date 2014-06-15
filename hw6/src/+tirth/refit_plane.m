function [ reg_depth , plane_pts3d ,FRes] = refit_plane( pts3d , fl_mask , ins_tx , ext_tx , depth_map)

if nargin <  5
    error('invalid');
end

assert(size(ins_tx,2)==3);
assert(size(ext_tx,2)==4);

%% the point require to remove R|Rt

pts4d=cat(2,pts3d,ones(size(pts3d,1),1));

pts4d_re=(ext_tx*pts4d')';

for k=1:3
    pts4d_re(k,:)=pts4d_re(k,:)./pts4d_re(4,:);
end

pts3d_w=pts4d_re(:,1:3);


inv_ext = inv(ext_tx);
%% [TASK] fit plane 

[FRes,inliers]=toolkit_g6_me.myRANSACFitPlane(pts3d_w');
 
 
%% re-estimate depth
 
fl_mask1d_eff=find(reshape(fl_mask,[],3));

Pmat=[ [ins_tx(1,:),0];
       [ins_tx(2,:),0];
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

camP = eye(4);
camP(1:3,1:3)=ins_tx;
camP=camP*ext_tx;

for k=1:numel(fl_mask1d_eff)
    
    ii=fl_mask1d_eff(k);
    
    [yy,xx]=ind2sub(size(fl_mask),ii);

    Pmat=[ fx,0,u-xx
           0 ,fy,v-yy
           abc
    ]; 

    p3d_w=mldivide(Pmat,[0,0,-d]');
    
    
    p3d_ori = (inv_ext * [p3d_w(1:3)',1]')';
    
    plane_3dh=cat(1,plane_3dh,p3d_ori(:)');
    
    %reg_depth(yy,xx)=p3d_ori(3);
    % YOU should record.. im_zval ( after z tx(R|Rt) ) not the original z val 
    reg_depth(yy,xx)=p3d_w(3);
end
 

%%

plane_pts3d = plane_3dh(:,1:3);

if 0
% use ori space
%debug_pts = pts3d;
%debug_pts = cat(1,debug_pts,plane_3dh(:,1:3)); 
%debug_pts(:,2)=-debug_pts(:,2);

figure(3);
showPointCloud_gui(plane_pts3d,plane_pts3d(:,3));

end


end

