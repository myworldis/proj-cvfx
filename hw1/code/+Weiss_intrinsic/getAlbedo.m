function [imR,dxs,dys,dx,dy,invKhat]=getAlbedo(bigIm1,invKhat)

dxs=0*bigIm1;
dys=0*bigIm1;
  
for i=1:size(bigIm1,3)
  dx=conv2(bigIm1(:,:,i),[0 1 -1],'same');
  dy=conv2(bigIm1(:,:,i),[0 1 -1]','same');
  dxs(:,:,i)=dx;
  dys(:,:,i)=dy;
end
dx=median(dxs,3);
dy=median(dys,3);

%%
if ~exist('invKhat')
  [imR,invKhat]=Weiss_intrinsic.reconsEdge3(dx,dy);
 % [imR]=reconsEdge2(dx,dy);
else
  imR=Weiss_intrinsic.reconsEdge3(dx,dy,invKhat);
end

