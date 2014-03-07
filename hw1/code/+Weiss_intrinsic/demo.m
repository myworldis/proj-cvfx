
tempDir = '../tmp';
mkdir(tempDir);
% make a demo of circle in square shadow
[x,y]=meshgrid(1:64);x=x-32;y=y-32;
circIm=x.^2+y.^2<15^2;


fnum=1;
bigIm1=zeros(64,64,2*fnum+1);

for i=-fnum:fnum
    im1=zeros(64);
    im1(i+32-20:i+32+20,i+32-20:i+32+20)=0.6;  % this puts shadow
    im1=im1+circIm;
    bigIm1(:,:,i+fnum+1)=im1;
    
    %imwrite(im1,strcat(tempDir,'_',num2str(i),'_.jpg'));
    
end

%%
% and now get albedo

% to debug
bigIm1=bigIm1+1;

% for boundary conditions we assume the boundary of the image
% is set to zero
bigIm1=zeroB(bigIm1,2);
 
[imR,dxs,dys,dx,dy,invKhat]=getAlbedo(bigIm1);
 
%figure(1);
%show(bigIm1(:,:,1));
%title('frame 1');
figure(2);
show(imR);
title('reflectance');
% to get lighting we subtract median lighting from the gradient
% and reconstruct

figure(3);
light1=reconsEdge3(dxs(:,:,1)-dx,dys(:,:,1)-dy,invKhat);
show(light1);
title('lighting frame 1');


