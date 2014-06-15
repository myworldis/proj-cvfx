function [ obb,aabb , obb_basis] = exbox( obj_pts3d , axis_1 ,plane_model, useFilter )
% 
% [ obb,aabb,basis] = exbox( obj_pts3d , axis_1 ,plane_model, useFilter )
% 
if nargin < 3
    error();
elseif nargin ==3
    useFilter=1;
end


if useFilter
        % remove plane pts
        good_flag=true(size(obj_pts3d,1),1);
        for i=1:numel(plane_model)
            err=error_plane(plane_model{i},obj_pts3d');
            if nnz(err<0.2)
                good_flag(err<1)=false;
            end
        end

        obj_pts3d=obj_pts3d(good_flag,:);

        %% knn filtering 

        % k-by-N
        dist=pdist2(obj_pts3d,obj_pts3d,'euclidean','Smallest',10);

        % n-k
        mdist=mean(dist',2);
        th_dist=median(mdist);

        goodFlag2 = mdist < th_dist*2;
        obj_pts3d=obj_pts3d(goodFlag2,:);
end
        
    %%
    [FRes]=toolkit_g6_me.myRANSACFitPlane(obj_pts3d');
    
    axis2=FRes.Theta(1:3);
    axis2=axis2./norm(axis2);
    
    axis3=cross(axis_1,axis2);
    
    % [b1,b2,b3]
    obb_basis=[axis_1(:),axis2(:),axis3(:)];
    
    
    [local_pts,c0]=cenTx(inv(obb_basis),obj_pts3d);
    aabb=getBBoxByPts3(local_pts);
    
    obb = cenTx(obb_basis,aabb,c0);
end

