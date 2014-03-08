% 
%
% test compose

k=1254;

af =double(read(vin, k))./255; 
af = imresize(af,ratio);
a_light=zeros(vHeight*ratio,vWidth*ratio,3);
    
for ich=1:3
    
    f=af(:,:,ich);
    f=Weiss_intrinsic.zeroB(f,2);
    a_dx=conv2(f,[0 1 -1],'same');
    a_dy=conv2(f,[0 1 -1]','same');
    a_light(:,:,ich)=Weiss_intrinsic.reconsEdge3( a_dx-calData.dx_rgb{ich} , a_dy-calData.dy_rgb{ich}, calData.khat_rgb{ich});

end

%% compose

comFrame = log( exp(retouchRimg).*exp(a_light) );

fimshow(comFrame);


