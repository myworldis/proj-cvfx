
cd('D:\nthu_school\CVFX\proj-cvfx\hw4\src');

addpath('../lib/GCMex');

dataPath = '../data/face';


mask = imread( fullfile( dataPath , 'mask.png' ) );

s1 = imread( fullfile( dataPath , 's1.png') );
s2 = imread( fullfile( dataPath , 's2_2.png') );


mask=sum(mask,3);
mask=mask>0;

assert(size(s1,1)==size(s2,1) && size(s2,2)==size(s2,2),'the size of s1&s2 is not match');
assert(size(s1,1)==size(mask,1) && size(mask,2)==size(s2,2),'the size of mask&s2 is not match');

%% resize
ratio=0.3;

bg=imresize(s1,ratio);
fg=imresize(s2,ratio);
fg_mask=imresize(mask,ratio);

fimshowpair(bg,fg);
fimshowpair(fg,fg_mask,'blend');

%%

% ignore border pixels
nnG = make4x4NN( fg );

%% setup Data cost

% bg,fg
NUM_OF_UNK = size(fg,1)*size(fg,2);

NUM_OF_LABEL = 2;

FG_LID=1;
BG_LID=2;

fg_mask1d = fg_mask(:);
 

dataCost = ones( NUM_OF_UNK, NUM_OF_LABEL );

fg_1=double(reshape(fg,[],3));
bg_1=double(reshape(bg,[],3));


fbgDiff = (fg_1 - bg_1);
fbgDiff = bsxfun(@minus,fg_1,[15,20,32]);
fbgDiff = sqrt(sum(fbgDiff.^2,2));

%bgDiff = bsxfun(@minus,bg_1,[15,20,32]);
%bgDiff = sqrt(sum(bgDiff.^2,2));

dataCost( fg_mask1d,FG_LID)=0;
dataCost(~fg_mask1d,FG_LID)=fbgDiff(~fg_mask1d,:);

dataCost( fg_mask1d,BG_LID)=2000; 
dataCost(~fg_mask1d,BG_LID)=0;


iniLabel( ~fg_mask1d )=BG_LID;
iniLabel( fg_mask1d )=FG_LID;

disp('done');

%% setup Pairwised cost
 
fg_gxy6d = getImgGXY6D(fg);
bg_gxy6d = getImgGXY6D(bg);

fg_1d = double(reshape(fg,[],3));
bg_1d = double(reshape(bg,[],3));

fg_dxy6d = reshape(fg_gxy6d,[],6);
bg_dxy6d = reshape(bg_gxy6d,[],6);

pairCost = zeros(size(fg,1),size(fg,2));

[uu,vv]=find(nnG);        

weiNNG = nnG;

mask_dist=bwdist(fg_mask);
mdist_1d = mask_dist(:);
for i=1:numel(uu)
    
    pIdx = uu(i);
    qIdx = vv(i);
    
    %xi = norm( fg_1d(pIdx,:)- bg_1d(qIdx,:) ); 
    x1 = norm( fg_1d(pIdx,:)- fg_1d(qIdx,:) ); 
    x2 = norm( bg_1d(pIdx,:)- bg_1d(qIdx,:) );
    
    y1 = norm( fg_dxy6d(pIdx,:)- fg_dxy6d(qIdx,:) ); 
    y2 = norm( bg_dxy6d(pIdx,:)- bg_dxy6d(qIdx,:) ); 
    
    weiNNG(pIdx,qIdx)=mdist_1d(qIdx)+mdist_1d(pIdx)+(x1+x2);
end

%% smooth 

mmat = ones(NUM_OF_LABEL,NUM_OF_LABEL);

lambda=1;

mmat(eye(NUM_OF_LABEL)>0)=0;

mmat = mmat * lambda;


%%
% >> h = GCO_Create(4,3);             % Create new object with NumSites=4, NumLabels=3
%      >> GCO_SetDataCost(h,[0 9 2 0;      % Sites 1,4 prefer  label 1
%                            3 0 3 3;      % Site  2   prefers label 2 (strongly)
%                            5 9 0 5;]);   % Site  3   prefers label 3

%      >> GCO_SetSmoothCost(h,[0 1 2;      % 
%                              1 0 1;      % Linear (Total Variation) pairwise cost
%                              2 1 0;]);   % 

%      >> GCO_SetNeighbors(h,[0 1 0 0;     % Sites 1 and 2 connected with weight 1
%                             0 0 1 0;     % Sites 2 and 3 connected with weight 1
%                             0 0 0 2;     % Sites 3 and 4 connected with weight 2
%                             0 0 0 0;]);
%      >> GCO_Expansion(h);                % Compute optimal labeling via alpha-expansion 
%      >> GCO_GetLabeling(h)


h = GCO_Create(NUM_OF_UNK,NUM_OF_LABEL); 

GCO_SetDataCost(h, (dataCost') );

GCO_SetSmoothCost(h, mmat );

GCO_SetNeighbors(h, weiNNG );

%GCO_SetLabeling(h,iniLabel);

GCO_Expansion(h);   

ll = GCO_GetLabeling(h);

ll2d=reshape(ll, size(fg_mask));
disp(unique(ll));
figure;
imagesc(ll2d);
axis image
%%

final =bg_1d;
final( ll2d == FG_LID , :)=fg_1d( ll2d == FG_LID  , :);

final = uint8(reshape(final,size(fg)));
figure;
imagesc(final);
axis image

%%












