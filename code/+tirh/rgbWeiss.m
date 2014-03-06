function [ refImg , illImg ] = rgbWeiss( rgbframes )


if nargin < 1 || ndims(rgbframes) ~=4 || size(rgbframes,3)~=3
   
    error('invalid');
end


if isa(rgbframes,'uint8')
    rgbframes = single(rgbframes)./255;
end


r_frs = squeeze(rgbframes(:,:,1,:));
g_frs = squeeze(rgbframes(:,:,1,:)); 
b_frs = squeeze(rgbframes(:,:,1,:));


ts = tic;

[imR,dxs,dys,dx,dy,invKhat]=getAlbedo(ds_f);
fimshow(imR);

disp('albedo DONE');

light1=reconsEdge3(dxs(:,:,1)-dx,dys(:,:,1)-dy,invKhat);

disp('light DONE');

toc(ts)




end

