% test data
%

imgs={};
imgs{end+1}=imread('../data/new2/DSCN1208.JPG');
imgs{end+1}=imread('../data/new2/DSCN1209.JPG');
imgs{end+1}=imread('../data/new2/DSCN1210.JPG');
imgs{end+1}=imread('../data/new2/DSCN1211.JPG');
imgs{end+1}=imread('../data/new2/DSCN1212.JPG');

disp('load done');

%%

ratio = 0.1;

smImgs=zeros(size(imgs{1},1)*ratio,size(imgs{2},2)*ratio,3,0);

for k=1:numel(imgs)
    
    aim = ( double(imresize(imgs{k},ratio))./255 );
    smImgs(:,:,:,end+1)=aim;
end

disp('done');

%% 
s1=[102,20];
s2=[380,199];

crect = [s1,s2-s1];

I2 = imcrop(aim, crect);
fimshow(I2);

%%


[rimg , limg , gimref , giml1 ]=tirth.rgbWeiss(smImgs);

% vis

fimshow(tirth.normalize(rimg));
title('reflectance');

fimshow(tirth.normalize(limg));
title('light of frame 1');

%%
comp=exp(log(rimg)+log(limg));
comp2=real(comp); 
comp2(comp2<0)=0;
fimshowpair(smImgs(:,:,:,1), tirth.normalize(comp2) );

title('re-comstruct');





