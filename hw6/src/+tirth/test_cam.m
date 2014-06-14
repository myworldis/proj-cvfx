cam_f_fpath = fullfile( CAM_DIR , sprintf('%.8d.txt',fid) );

fin=fopen(cam_f_fpath,'r');

ss=fgets(fin);

cam_mat=fscanf(fin,'%f',[4,3]);
cam_mat=cam_mat';
fclose(fin);

%%
[R,Q,Qx,Qy,Qz] =cv.RQDecomp3x3(camera_f1(1:3,1:3));

tx=camera_f1(:,4);

cK=R;
cR=Q;
ct=inv(Q)*inv(cK)*tx;

disp(camera_f1);
disp(cK*[cR , cR*ct ]);

% k[R|t] = 

ins_tx = [cK,[0,0,0]'];
ext_tx = [cR,cR*ct];
ext_tx = cat(1,ext_tx,[0,0,0,1]);