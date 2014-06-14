function [ cK,ext_tx,cR,ct ] = excamera( camera_f1 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[R,Q,Qx,Qy,Qz] =cv.RQDecomp3x3(camera_f1(1:3,1:3));

tx=camera_f1(:,4);

cK=R;
cR=Q;
ct=inv(Q)*inv(cK)*tx;
 

% k[R|t] = 

ins_tx = [cK,[0,0,0]'];
ext_tx = [cR,cR*ct];
ext_tx = cat(1,ext_tx,[0,0,0,1]);

end

