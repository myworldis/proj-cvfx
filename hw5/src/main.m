


% resize input 


%inputPath='D:\nthu_school\CVFX\proj-cvfx\hw5\data\IMG_0795.MOV';
%outPath = 'D:/nthu_school/CVFX/proj-cvfx/hw5/data/IMG_0795rr.avi';

inputPath = fullfile(gdef.dataroot,'IMG_0789.MOV');
r_inputPath = fullfile(gdef.dataroot,'IMG_0789_480rr.avi');

if 0
    tirth.video_preprocess(inputPath,r_inputPath,480,-90);
end

vobj = tirth.VideoProxy();

vobj.load(r_inputPath);
 
%% calculate H from t0 to ti

%vout=VideoWriter('stabilization.avi','Motion JPEG AVI' );
%open(vout); 
startF = vobj.getFrame(1);

ib=1;
iend=ib+50;  %nFrames/2

all_H={};
frameIdx=[];

% Tx frame K_i to frame K_0

for k = ib:iend
    all_H{end+1} = tirth.match_sift(startF, vobj.getFrame(k) );
    frameIdx(end+1)=k;
    fprintf('calculate warping- %d/%d\n',k-ib+1,iend-ib+1);
end

save('all_H','all_H');

%%  2D affine tx SMOOTHING
% 
% N x 9
close all;

hmat=[];
for k=1:numel(all_H)
    kh=all_H{k}.T(:);
    hmat=cat(1,hmat,kh');
end

figure;
ctable = hsv(40);

len_name={'r1','r2','TX','r3','r4','TY','7','8','9'};

for k=1:6
    figure;
    plot(1:size(hmat,1) , hmat(:,k) ,'color',ctable(k,:),'linewidth',2 );hold on;
    title(len_name{k});
    axis equal; grid on;
end

%legend('r1','r2','TX','r3','r4','TY','7','8','9');


% DO smoothing

s_hmat=hmat;

s_hmat(:,3)=smooth(hmat(:,3),'moving');
s_hmat(:,6)=smooth(hmat(:,6),'moving');

smooTime=3;
sMX_hmat=hmat;
for i=1:smooTime
    sMX_hmat(:,3)=smooth(sMX_hmat(:,3),'moving');
    sMX_hmat(:,6)=smooth(sMX_hmat(:,6),'moving');
end

for k=[3,6]
    figure;
    plot(1:size(hmat,1) , hmat(:,k) ,'color',ctable(k,:),'linewidth',2 );hold on;
    plot(1:size(hmat,1) , s_hmat(:,k) ,'color',ctable(k+10,:),'linewidth',2 );hold on;
    plot(1:size(hmat,1) , sMX_hmat(:,k) ,'color',ctable(k+30,:),'linewidth',2 );hold on;
    
    title(len_name{k});
    axis equal; grid on;
end

%% calculate H from ti-1 to ti


vobj = tirth.VideoProxy();
vobj.load(r_inputPath);
startF = vobj.getFrame(1);

ib=2;
iend=ib+50;  %nFrames/2

all_tij={};
frameIdx=[];

% Tx frame K_i to frame K_0

for k = ib:iend
    all_tij{end+1} = tirth.match_sift(vobj.getFrame(k-1), vobj.getFrame(k) );
    frameIdx(end+1)=k;
    fprintf('calculate warping- %d/%d\n',k-ib+1,iend-ib+1);
end

save('all_tij','all_tij');

%% vis TX
%
% 2D affine tx SMOOTHING
% 
% N x 9
close all;

hmat=[];
for k=1:numel(all_tij)
    kh=all_tij{k}.T(:);
    hmat=cat(1,hmat,kh');
end

figure;
ctable = hsv(40);

len_name={'r1','r2','TX','r3','r4','TY','7','8','9'};

for k=1:6
    figure;
    plot(1:size(hmat,1) , hmat(:,k) ,'color',ctable(k,:),'linewidth',2 );hold on;
    plot(1:size(hmat,1) , hmat(:,k) ,'+','color',[0,0,0] ,'linewidth',1.5);hold on;
    title(len_name{k});
    axis equal; grid on;
end

%legend('r1','r2','TX','r3','r4','TY','7','8','9');



%%  DO smoothing

s_hmat=hmat;

s_hmat(:,3)=smooth(hmat(:,3),'moving');
s_hmat(:,6)=smooth(hmat(:,6),'moving');

smooTime=3;
sMX_hmat=hmat;
for i=1:smooTime
    sMX_hmat(:,3)=smooth(sMX_hmat(:,3),'moving');
    sMX_hmat(:,6)=smooth(sMX_hmat(:,6),'moving');
end

for k=[3,6]
    figure;
    plot(1:size(hmat,1) , hmat(:,k) ,'color',ctable(k,:),'linewidth',2 );hold on;
    plot(1:size(hmat,1) , s_hmat(:,k) ,'color',ctable(k+10,:),'linewidth',2 );hold on;
    plot(1:size(hmat,1) , sMX_hmat(:,k) ,'color',ctable(k+30,:),'linewidth',2 );hold on;
    
    title(len_name{k});
    axis equal; grid on;
end


all_tij_smoo = all_tij;

for k=1:numel(all_tij)
   all_tij_smoo{1}.T = reshape( sMX_hmat(k,:) , 3,3 ); 
end


%% regenerate debug video

vinObj= tirth.VideoProxy();
vinObj.load(outPath);
 
f2d=figure('Visible', 'off');

compFName='./tmp_sm_comp.avi'; 
outFName='./tmp_sm.avi';

vout_comp= VideoWriter(compFName);  
vout_comp.open();

vout = VideoWriter(outFName);  
vout.open();

cur_hmat = all_tij{1};
cur_hmat.T = eye(3);

txH_set = all_tij;
smoothTx_set = all_tij_smoo;

% write first frame
vout.writeVideo(vinObj.getFrame(1));

for k = 1:numel(frameIdx)

    fid=frameIdx(k);

    ori_frame_k = vinObj.getFrame(fid);
    
    ori_tx = txH_set{k};
    smo_tx = smoothTx_set{k}; 
    
    cur_hmat.T = smo_tx.T * cur_hmat.T;
    
    imgBp = imwarp(ori_frame_k, ori_tx, 'OutputView', imref2d(size(ori_frame_k)));
    imgBp_smo = imwarp(ori_frame_k, cur_hmat, 'OutputView', imref2d(size(ori_frame_k)));
    
    %%
    imshow(ori_frame_k,'border','tight');
    text
    textborder(50,size(ori_frame_k,1)*0.95,sprintf('f ID=%d',fid),[1,1,1],[0,0,0],'FontSize',20);
       
    f=getframe;
    oriimg=f.cdata;
    clf;
    imshowpair(ori_frame_k,imgBp,'diff');
    f=getframe;
    smoImg=f.cdata(2:end,2:end,:); 
    
    %%
    catImg = cat(2,smoImg,oriimg,imgBp_smo);
    
    vout.writeVideo(imgBp_smo);
    vout_comp.writeVideo(catImg);
    %vout_smo.writeVideo(imgBp_smo);
    
    fprintf(' %d/%d\n',k , numel(frameIdx) );
end

vout_comp.close();
vout.close();

%% ========= crop black video =====================================

vobj = tirth.VideoProxy();
vobj.load(outFName);

black_mask=ones(size(vobj.getFrame(1),1),size(vobj.getFrame(1),2));

for k=1:vobj.video_file.NumberOfFrames
   
    f=vobj.getFrame(k);
    f=sum(f,3);
    
    black_mask(f<10)=0;
end
 
fimshow(black_mask);

crop_min=[134,69];
crop_max=[446,693];
crect = [crop_min,crop_max-crop_min];

cmask = imcrop(black_mask,crect);
fimshow( cmask );

%% ========= regenerate result image =====================================

f2d=figure('Visible', 'off');
 
res_outFName='./res_sm.avi';

vori_obj = tirth.VideoProxy();
vori_obj.load(r_inputPath); 

vout = VideoWriter(res_outFName);  
vout.open();

for k = 1:numel(frameIdx)

    fid=frameIdx(k);

    ori_frame_k = vobj.getFrame(fid);
    
    input_frame = vori_obj.getFrame(fid);
    
    res_f=imcrop(ori_frame_k,crect);
    input_f=imcrop(input_frame,crect);
    
    catImg = cat(2,input_f,res_f);
    
    vout.writeVideo(catImg);
    
    fprintf(' %d/%d\n',k , numel(frameIdx) );
    
    
end

vout.close();



%%
%
% transformPointsForwardApply forward geometric transformation 
% transformPointsInverseApply inverse geometric transformation
% 

imgBp = imwarp(ori_frame_k, ori_tx, 'OutputView', imref2d(size(ori_frame_k)));
fimshowpair(ori_frame_k,imgBp,'diff' );
fimshowpair(ori_frame_k,imgBp );

% pointsBmp = transformPointsForward(tform, pointsBm.Location);



