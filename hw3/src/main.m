%
%
%

root='../data';

im1=imread(fullfile(root,'venus.png'));
im2=imread(fullfile(root,'monalisa.png'));
im3=imread(fullfile(root,'mask.png'));


im1=imread(fullfile(root,'2.jpg'));
im2=imread(fullfile(root,'1.jpg'));
im3=imread(fullfile(root,'mask_.jpg'));

F=lib.poisson(im1,im2,im3);

fimshowpair(im1,F);

%% small test

m=1:12;
m=reshape(m,3,[])';
h=3;
disp(m)
%circshift(m,[0,1])
%circshift(m,[1,0])

% n-th element specifies the shift 
% amount for the n-th dimension
% of array A.
circshift(m,[0,2])



%% 

im1=imread(fullfile(root,'im1_32.png'));
im2=imread(fullfile(root,'im2_32.png'));
im3=imread(fullfile(root,'mask_32.png'));

F=lib.my_poisson(im1,im2,im3);

fimshowpair(im1,im2);
fimshowpair(im3,F);



%%
 
F=lib.my_poisson(im1,im2,im3);

fimshowpair(im1,im2);
fimshowpair(im3,F);














