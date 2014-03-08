function [ refImg , lightImg ,calData ] = rgbWeiss( rgbframes )


if nargin < 1 || ndims(rgbframes) ~=4 || size(rgbframes,3)~=3
   
    error('invalid');
end

verbase = false;


if isa(rgbframes,'uint8')
    rgbframes = double(rgbframes)./255;
end

% must do
rgbframes=Weiss_intrinsic.zeroB(rgbframes,2);

r_frs = squeeze(rgbframes(:,:,1,:));
g_frs = squeeze(rgbframes(:,:,2,:)); 
b_frs = squeeze(rgbframes(:,:,3,:));


refImg=zeros(size(rgbframes,1),size(rgbframes,2),3);
lightImg=zeros(size(rgbframes,1),size(rgbframes,2),3);


calData = struct;
calData.khat_rgb={};
calData.dx_rgb={};
calData.dy_rgb={};

ts = tic;
[refImg(:,:,1),lightImg(:,:,1),calData.khat_rgb{end+1},calData.dx_rgb{end+1},calData.dy_rgb{end+1}]=calc(r_frs);
[refImg(:,:,2),lightImg(:,:,2),calData.khat_rgb{end+1},calData.dx_rgb{end+1},calData.dy_rgb{end+1}]=calc(g_frs);
[refImg(:,:,3),lightImg(:,:,3),calData.khat_rgb{end+1},calData.dx_rgb{end+1},calData.dy_rgb{end+1}]=calc(b_frs);
toc(ts)

%% gray version
% 
% gims = zeros(size(rgbframes,1),size(rgbframes,2),0);
% for k=1:size(rgbframes,4)
%     gim = rgb2gray(rgbframes(:,:,:,k));
%     gims(:,:,end+1)=gim;
% end
% 
% 
% [gimref , giml1 ]=calc(gims);

gimref=[];

giml1=[];


end


function [imR,light1,invKhat,dx,dy]=calc(frames)


[imR,dxs,dys,dx,dy,invKhat]=Weiss_intrinsic.getAlbedo(frames);


disp('albedo DONE');

light1=Weiss_intrinsic.reconsEdge3(dxs(:,:,1)-dx,dys(:,:,1)-dy,invKhat);

disp('light DONE');

end