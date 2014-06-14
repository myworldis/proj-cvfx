%
setup;

%%

tirth.video_preprocess( fullfile(gdef.dataroot,'video','IMG_0834.MOV') , ...
                        fullfile(gdef.dataroot,'video','IMG_0834_480.avi')   , 480 , 0 );

%% expose frames


INP_VPATH=fullfile(gdef.dataroot,'video','IMG_0834_480.avi') ;
F_SAVDIR =fullfile(gdef.dataroot,'video','IMG_0834_480_frame') ;
tirth.mkdir_if(F_SAVDIR);

inpVideo=tirth.VideoProxy();

inpVideo.load(INP_VPATH);

for k=1:inpVideo.totalFrame()
      
  f=inpVideo.getFrame(k);
  imname = fullfile(F_SAVDIR,sprintf('f_%d.ppm',k-1)); 
    
  imwrite(f,imname);
  
  fprintf('pass %d/%d\n',k,inpVideo.totalFrame());
  
end
%% 827

tirth.video_preprocess( fullfile(gdef.dataroot,'video','IMG_0827.MOV') , ...
                        fullfile(gdef.dataroot,'video','IMG_0827_480.avi')   , 480 , 0 );

%%

INP_VPATH=fullfile(gdef.dataroot,'video','IMG_0827_480.avi') ;
F_SAVDIR =fullfile(gdef.dataroot,'video','IMG_0827_480_frame') ;
tirth.mkdir_if(F_SAVDIR);

inpVideo=tirth.VideoProxy();

inpVideo.load(INP_VPATH);

for k=1:inpVideo.totalFrame()
      
  f=inpVideo.getFrame(k);
  imname = fullfile(F_SAVDIR,sprintf('f_%d.ppm',k-1)); 
    
  imwrite(f,imname);
  
  fprintf('pass %d/%d\n',k,inpVideo.totalFrame());
  
end

