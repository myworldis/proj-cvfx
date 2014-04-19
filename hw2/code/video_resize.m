%
% video resize
%
function []=video_resize(vinPath,voutPath,ratio)

% ratio = 720/1080;

if nargin < 3
    error('invalid');
end

if ~exist(vinPath,'file')
    
end

vin=VideoReader(vinPath);
vout=VideoWriter(voutPath,'Motion JPEG AVI' );

num = vin.NumberOfFrames;

vWidth = vin.Width;
vHeight = vin.Height;
 
disp(vinPath);
fprintf('input w,h = %d,%d \n',vWidth,vHeight);
fprintf('output w,h = %.0f,%.0f \n',vWidth*ratio,vHeight*ratio);
disp('start-');
open(vout); 

for k=1:num 
    aframe =uint8(read(vin, k)); 
    rs_frame = ( (imresize(aframe,ratio)) );
     
    writeVideo(vout, rs_frame);
    
    if mod(k,50)==0
        fprintf(' %d/%d\n',k,num);
    end
end
close(vout);

disp('ALL done');

end

