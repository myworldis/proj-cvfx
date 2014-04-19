%
% get f1
%
 

fpath ='../res/ta_comp_impv1_final_crp.mp4';
fpath ='../res/our_comp_impv1_final_cpr.mp4';
fpath ='../data/IMG_0549.MOV';
fpath ='../data/new2/DSCN1213.MOV';

v1=VideoReader(fpath); 

num = v1.NumberOfFrames;
vWidth = v1.Width;
vHeight = v1.Height;


k=1;
aframe =uint8(read(v1, k));

fimshow(aframe,'border','tight');
