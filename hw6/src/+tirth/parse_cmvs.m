%
%
%
% parsing CMVS output
%
% 

CAM_FPATH =fullfile(gdef.dataroot,'video','0834','dense\v1fix.nvm.cmvs\00\cameras_v2.txt');

CAM_DIR = fullfile(gdef.dataroot,'video','0834\dense\v1fix.nvm.cmvs\00\txt');

SYNC_CAM_DIR = fullfile(gdef.dataroot,'video','0834','sync_camtxt');
Rt_CAM_SAVDIR = fullfile(gdef.dataroot,'video','0834','sync_rt_txt');

mkdir_if(Rt_CAM_SAVDIR);

%%
fin=fopen(CAM_FPATH,'r');

allline={};

tline = fgetl(fin);
while ischar(tline)
    allline{end+1}=(tline);
    tline = fgetl(fin);
end

fclose(fin);

%% get cam_frame_ids

[matchStr ]=regexp(allline,'f_[0-9]+\.ppm','match');

ef_flag=cellfun(@(x)~isempty(x),matchStr);
ef_str=matchStr(ef_flag);

mstrs=cellfun(@(x)x{:},ef_str,'uniformoutput',false); 

[ cam_frame_ids ]=my_module.gt_tool.regNumFilter(mstrs);

%% re saving

[olist]=my_module.gt_tool.getPathList(CAM_DIR,'.txt');

total_f = numel(cam_frame_ids);

% 0.matrix -> fid(0+1)

[sval,sidx]=sort(cam_frame_ids,'ascend');

% frame_id -> (k-1).matrix
% sval 

sysbat=fopen('copy_.bat','w');

for k=1:total_f
    % the fid of 
    fid=k;
    cam_fid = sidx(k)-1; 
    
    camFname = fullfile(CAM_DIR,sprintf('%.8d.txt',cam_fid ));
    reFname = fullfile(SYNC_CAM_DIR ,sprintf('%d.txt',fid));
    % copy file
    fprintf(sysbat,'COPY %s   %s \n',camFname,reFname);
end
fclose(sysbat);

%% extract all R|Rt


clist = my_module.gt_tool.getPathList(SYNC_CAM_DIR,'.txt');

allcam={};
allidx=[];

for k=1:numel(clist)
    
campath=fullfile(SYNC_CAM_DIR,clist{k});

[~,fn,ext]=fileparts(clist{k});

fin=fopen(campath,'r');

ss=fgets(fin);

cam_mat=fscanf(fin,'%f',[4,3]);
fclose(fin);

allcam{end+1}=cam_mat';
allidx(end+1)=str2num(fn);
 
end

%%
fix_k=[
893.533447266 0 427 
0 893.533447266 240 
0 0 1  
];


% extract and save at Rt_CAM_SAVDIR
% 
for k=1:numel(allcam)
    
    fid=allidx(k);
    
    [cK , exttx , R , t ]=tirth.excamera_fix(allcam{k},fix_k);
      
    final_Rt =(exttx); 

    %  The first three elements specify the rotation axis, and the last element defines the angle of rotation.
    axisAngle = vrrotmat2vec(final_Rt(1:3,1:3));
    rAxis=axisAngle(1:3);
    rangle=axisAngle(4);
    
    wxyz=[rangle,rAxis]; 
    Rtx = final_Rt(1:3,4)';
    
    % save out
    fname=fullfile(Rt_CAM_SAVDIR,sprintf('%d.txt',fid));
    fout=fopen(fname,'w');
    
    fprintf(fout,'%f %f %f %f\n',wxyz);
    fprintf(fout,'%f %f %f\n',Rtx);
    
    fprintf(fout,'\n');
    fclose(fout);
    
    fprintf('pass fid.%d\n',fid);
     
end

disp('all done.');






