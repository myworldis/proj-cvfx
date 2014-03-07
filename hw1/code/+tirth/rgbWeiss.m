function [ refImg , lightImg , gimref , giml1 ] = rgbWeiss( rgbframes )


if nargin < 1 || ndims(rgbframes) ~=4 || size(rgbframes,3)~=3
   
    error('invalid');
end

verbase = false;


if isa(rgbframes,'uint8')
    rgbframes = double(rgbframes)./255;
end


r_frs = squeeze(rgbframes(:,:,1,:));
g_frs = squeeze(rgbframes(:,:,2,:)); 
b_frs = squeeze(rgbframes(:,:,3,:));


refImg=zeros(size(rgbframes,1),size(rgbframes,2),3);
lightImg=zeros(size(rgbframes,1),size(rgbframes,2),3);

ts = tic;
[refImg(:,:,1),lightImg(:,:,1)]=calc(r_frs);
[refImg(:,:,2),lightImg(:,:,2)]=calc(g_frs);
[refImg(:,:,3),lightImg(:,:,3)]=calc(b_frs);
toc(ts)

%% gray version

gims = zeros(size(rgbframes,1),size(rgbframes,2),0);
for k=1:size(rgbframes,4)
    gim = rgb2gray(rgbframes(:,:,:,k));
    gims(:,:,end+1)=gim;
end


[gimref , giml1 ]=calc(gims);

end


function [imR,light1 ]=calc(frames)


[imR,dxs,dys,dx,dy,invKhat]=Weiss_intrinsic.getAlbedo(frames);


disp('albedo DONE');

light1=Weiss_intrinsic.reconsEdge3(dxs(:,:,1)-dx,dys(:,:,1)-dy,invKhat);

disp('light DONE');

end