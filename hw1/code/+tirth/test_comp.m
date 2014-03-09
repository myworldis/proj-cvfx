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

[rt_rimg,~,alpha_s] = tirth.myimread('../data/test_rt_new_ta.png');   
[bk_rimg]= tirth.myimread('../data/test_rt_bk_ta.png');   


rt_rimg =imresize(rt_rimg,ratio);
bk_rimg =imresize(bk_rimg,ratio);
alpha_s = imresize(alpha_s,ratio);

alpha = cat(3,alpha_s,alpha_s,alpha_s);


% max saturation
maxSat = max(rimg,[],3); 
maxSat = cat(3,maxSat,maxSat,maxSat);

compRimg = rt_rimg.*alpha.*maxSat+bk_rimg.*(1-alpha);

fimshow(compRimg);

%%

 
ath=0.001;

effMask = alpha_s>ath;

r_luImg1d = reshape(a_light,[],3);
r_luImg1d(effMask,1) = (1-alpha_s(effMask)).*luImg1d(effMask,1)+(alpha_s(effMask)).*min(luImg1d(effMask,:),[],2);
r_luImg1d(effMask,2) = (1-alpha_s(effMask)).*luImg1d(effMask,2)+(alpha_s(effMask)).*min(luImg1d(effMask,:),[],2);
r_luImg1d(effMask,3) = (1-alpha_s(effMask)).*luImg1d(effMask,3)+(alpha_s(effMask)).*min(luImg1d(effMask,:),[],2);

luImg = reshape( r_luImg1d,size(a_light));


comFrame =  (compRimg)+(luImg);
  
fimshow(tirth.clamp(comFrame),'border','tight');

fimshow(tirth.clamp(compRimg+a_light),'border','tight');
fimshow(tirth.clamp(rimg+a_light),'border','tight');



