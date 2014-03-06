
addpath('./Weiss_intrinsic/');
 

warrn_id = 'images:initSize:adjustingMag';
warning('off',warrn_id)

%%
ROOT = '../data';

f1='IMG_0549.MOV';
f2='IMG_0550.MOV';
f3='IMG_0562.MOV';

v1=VideoReader(fullfile(ROOT,f1) );

num = v1.NumberOfFrames;

%% load some data

frames=zeros(v1.Height,v1.Width,3,0,'uint8');
for k=1:30:num
    frames(:,:,:,end+1) =uint8(read(v1, k));
end


%% pick frames

ratio = 0.25;

ds_f = zeros(size(frames,1)*ratio ,  size(frames,2)*ratio , 3 , 0);
ds_idx = [];

for k=1:5:size(frames,4)  
    gim = ( double(imresize(frames(:,:,:,k),ratio))./255 );
    ds_f(:,:,:, end+1) = gim ;
    ds_idx(end+1)=k;
end
 %% vis
 
figure;

for k=1:size(frames,4)
    imshow(frames(:,:,:,k));
    title(strcat('frame-',num2str(k)));
    pause
end

figure;

for k=1:size(ds_f,4)
    imshow(ds_f(:,:,:,k));
    title(num2str(k));
    pause
end

%%


[rimg , limg]=tirth.rgbWeiss(ds_f);

fimshow(rimg);
title('reflectance');

fimshow(limg);
title('light of frame 1');

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












