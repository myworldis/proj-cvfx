function []=reconstrAll_mat( writerObj , vinObj ,rimg, rimgRtFname,rimgBKFname , calData ,ratio )
% []=reconstrAll_mat( writerObj , vinObj , rimgRtFname,rimgBKFname   , calData ,ratio )

if nargin < 6
    error('invalid'); 
end

%calData.khat_rgb={};
%calData.dx_rgb={};
%calData.dy_rgb={};

numF = vinObj.NumberOfFrames;
vWidth = vinObj.Width;
vHeight = vinObj.Height;
 
[rt_rimg,~,alpha_s] = tirth.myimread(rimgRtFname);   
[bk_rimg]= tirth.myimread(rimgBKFname);   

rt_rimg =imresize(rt_rimg,ratio);
bk_rimg =imresize(bk_rimg,ratio);
alpha_s = imresize(alpha_s,ratio);
alpha = cat(3,alpha_s,alpha_s,alpha_s);

ath=0.001;
effMask = alpha_s>ath;
 

al_deff=1-alpha_s(effMask);
al_eff=alpha_s(effMask);

% max saturation
maxSat = max(rimg,[],3); 
maxSat = cat(3,maxSat,maxSat,maxSat);

compRimg = rt_rimg.*alpha.*maxSat+bk_rimg.*(1-alpha);

for k=1:numF
 
    af =double(read(vinObj, k))./255; 
    af = imresize(af,ratio);
     
    a_light=zeros(vHeight*ratio,vWidth*ratio,3);
    
    for ich=1:3
        
        [a_dx,a_dy]=framePreprocess(af(:,:,ich)); 
        a_light(:,:,ich)=Weiss_intrinsic.reconsEdge3( a_dx-calData.dx_rgb{ich} , a_dy-calData.dy_rgb{ich}, calData.khat_rgb{ich});
         
    end
    
    %% matting
    luImg1d = reshape(a_light,[],3);
    r_luImg1d = reshape(a_light,[],3);
    min_eff_lu = min(luImg1d(effMask,:),[],2);
    
    %r_luImg1d(effMask,3) = (1-alpha_s(effMask)).*luImg1d(effMask,3)+(alpha_s(effMask)).*min(luImg1d(effMask,:),[],2);
    r_luImg1d(effMask,1) = (al_deff).*luImg1d(effMask,1)+(al_eff).*min_eff_lu;
    r_luImg1d(effMask,2) = (al_deff).*luImg1d(effMask,2)+(al_eff).*min_eff_lu;
    r_luImg1d(effMask,3) = (al_deff).*luImg1d(effMask,3)+(al_eff).*min_eff_lu;
    
    luImg = reshape( r_luImg1d,size(a_light));
    
    %% compose this frame
    
    comFrame =  (compRimg)+(luImg);
    comFrame= tirth.clamp(comFrame);
    
    writeVideo(writerObj, comFrame);
    
    if 0==rem(k,10)
        fprintf('pass %d/%d\n',k,numF);
    end
    
end


disp('DONE');



end


function [dx,dy]=framePreprocess(f)
    f=Weiss_intrinsic.zeroB(f,2);
    dx=conv2(f,[0 1 -1],'same');
    dy=conv2(f,[0 1 -1]','same');
end




