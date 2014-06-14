function [ cK,ext_tx,cR,ct ] = excamera_fix( camera_f1 , cK )
% [ cK,ext_tx,R,t ] = excamera_fix( camera_f1 , cK )
%
% K [R|Rt] 
%



KR=camera_f1(1:3,1:3);


% K [R|Rt]
 

cR=inv(cK)*KR;

tx=camera_f1(:,4);

ct=inv(cR)*inv(cK)*tx;
 
 
ext_tx = [cR,cR*ct];
ext_tx = cat(1,ext_tx,[0,0,0,1]);

end

