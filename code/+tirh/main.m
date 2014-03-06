
addpath('./Weiss_intrinsic/');


%%

warrn_id = 'images:initSize:adjustingMag';
warning('off',warrn_id)

%%
ROOT = '../data';

f1='IMG_0549.MOV';
f2='IMG_0550.MOV';
f3='IMG_0562.MOV';

v1=VideoReader(fullfile(ROOT,f1) );

num = v1.NumberOfFrames;

%%

frames=zeros(v1.Height,v1.Width,3,0,'uint8');
for k=1:30:num
    frames(:,:,:,end+1) =uint8(read(v1, k));
end

%%
figure;

for k=1:size(frames,4)
    imshow(frames(:,:,:,k));
    title(num2str(k));
    pause
end
%%

ratio = 0.1;

ds_f = zeros(size(frames,1)*ratio ,  size(frames,2)*ratio , 0);

for k=1:5:size(frames,4)  
    gim = rgb2gray( double(imresize(frames(:,:,:,k),ratio))./255 );
    ds_f(:,:,end+1) = gim ;
    
end
 

%%
 
ts = tic;

[imR,dxs,dys,dx,dy,invKhat]=getAlbedo(ds_f);
fimshow(imR);

disp('albedo DONE');

light1=reconsEdge3(dxs(:,:,1)-dx,dys(:,:,1)-dy,invKhat);

disp('light DONE');

toc(ts)


%%

figure(2);
show(imR);
title('reflectance');

% to get lighting we subtract median lighting from the gradient
% and reconstruct

figure(3);
show(light1);
title('lighting frame 1');












