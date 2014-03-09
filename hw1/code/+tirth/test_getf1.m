%
% get f1
%
 

v1=VideoReader('../res/ta_comp_impv1_final_crp.mp4');

num = v1.NumberOfFrames;
vWidth = v1.Width;
vHeight = v1.Height;


k=1;
aframe =uint8(read(v1, k));

fimshow(aframe,'border','tight');

%%


v1=VideoReader('../res/our_comp_impv1_final_cpr.mp4');

num = v1.NumberOfFrames;
vWidth = v1.Width;
vHeight = v1.Height;


k=1;
aframe =uint8(read(v1, k));

fimshow(aframe,'border','tight');
