%
%
%


root='../data';

im1=imread(fullfile(root,'venus.png'));
im2=imread(fullfile(root,'monalisa.png'));
im3=imread(fullfile(root,'mask.png'));


im1 = double(im1)/255.0;
im2 = double(im2)/255.0;
im3 = double(im3)/255.0;


%%

F=lib.poisson(im1,im2,im3);


fimshowpair(im1,F);