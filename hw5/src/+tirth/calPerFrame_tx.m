function [ output_args ] = calPerFrame_tx( vobj , ib , iend )
% 
%
%
%

if ~isa(vobj,'tirth.VideoProxy')
    error('tirth.VideoProxy');
end

if nargin == 1
    ib=1;
    iend=vobj.totalFrame();
end
    

for k = ib:iend
    all_H{end+1} = tirth.match_sift(startF, vobj.getFrame(k) );
    frameIdx(end+1)=k;
    fprintf('calculate warping- %d/%d\n',k-ib+1,iend-ib+1);
end

 
end


function matching_sift(im1,im2)









end