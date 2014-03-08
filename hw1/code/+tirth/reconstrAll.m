function []=reconstrAll( writerObj , vinObj , refImg , calData ,ratio )
% []=reconstrAll( writerObj , vinObj , refImg , calData ,ratio )

if nargin < 2
    error('invalid');
elseif nargin ==2
    ratio=1;
end

%calData.khat_rgb={};
%calData.dx_rgb={};
%calData.dy_rgb={};

numF = vinObj.NumberOfFrames;
vWidth = vinObj.Width;
vHeight = vinObj.Height;p
 
for k=1:20 %numel(numF)
 
    af =double(read(vinObj, k))./255;
    
    af = imresize(af,ratio);
    
    
    a_light=zeros(vHeight,vWidth,3);
    
    for ich=1:3
        
        [a_dx,a_dy]=framePreprocess(af(:,:,ich)); 
        a_light(:,:,ich)=Weiss_intrinsic.reconsEdge3( a_dx-calData.dx_rgb{ich},a_dy-calData.dy_rgb{ich},calData.khat_rgb{ich});
         
    end
    
    % compose this frame
    comFrame = refImg + a_light;
    
    comFrame(comFrame>1)=1;
    comFrame(comFrame<0)=0;
    
    writeVideo(writerObj, comFrame);
end


disp('light DONE');



end


function [dx,dy]=framePreprocess(f)
    f=Weiss_intrinsic.zeroB(f,2);
    dx=conv2(f,[0 1 -1],'same');
    dy=conv2(f,[0 1 -1]','same');
end




