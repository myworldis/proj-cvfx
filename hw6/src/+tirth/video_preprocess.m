function []=video_preprocess(vinPath,voutPath, fixHeight , rotAngle)
% []=video_preprocess(vinPath,voutPath, fixHeight=480 , rotAngle=0)
% ratio = 720/1080;

if nargin < 2
    error('invalid');
elseif nargin == 2
    fixHeight=480;
    rotAngle=0; 
elseif nargin ==3 
    rotAngle=0; 
end

fprintf('fixHeight = %d , rot = %d \n',fixHeight , rotAngle );

if ~exist(vinPath,'file')
    
end

vin=VideoReader(vinPath);

[pathstr, fname, ext]=fileparts(voutPath);
if ~strcmp(ext,'.avi') && ~strcmp(ext,'.AVI') 
    
    voutPath=fullfile(pathstr,fname,'.avi');
    fprintf('[**]save as Motion JPEG AVI\n'); 
end


vout=VideoWriter(voutPath,'Motion JPEG AVI' );

num = vin.NumberOfFrames; 
vWidth = vin.Width;
vHeight = vin.Height; 

ratio = fixHeight/vHeight;

disp(vinPath);
fprintf('input w,h = %d,%d \n',vWidth,vHeight);
fprintf('output w,h = %.0f,%.0f \n',vWidth*ratio,vHeight*ratio);
disp('start-');
open(vout); 


for k=1:num 
    aframe =uint8(read(vin, k)); 
    rs_frame = ( (imresize(aframe,ratio)) );
     
    rs_frame=imrotate(rs_frame,rotAngle);
    
    writeVideo(vout, rs_frame);
    
    if mod(k,50)==0
        fprintf(' %d/%d\n',k,num);
    end
end

close(vout);

[~, fname, ext]=fileparts(voutPath);
disp('ALL done');
fprintf('file[%s] save at [%s]\n', strcat(fname, ext) ,voutPath);

end

