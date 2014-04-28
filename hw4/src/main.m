

cd('D:\nthu_school\CVFX\proj-cvfx\hw4\src');

addpath('../lib/GCMex');

dataPath = '../data/face';


mask = imread( fullfile( dataPath , 'mask.png' ) );

s1 = imread( fullfile( dataPath , 's1.png') );
s2 = imread( fullfile( dataPath , 's2.png') );


mask=sum(mask,3);
mask=mask>0;

assert(size(s1,1)==size(s2,1) && size(s2,2)==size(s2,2),'the size of s1&s2 is not match');

assert(size(s1,1)==size(mask,1) && size(mask,2)==size(s2,2),'the size of mask&s2 is not match');

%% resize

bg=imresize(s1,0.25);
fg=imresize(s2,0.25);
fg_mask=imresize(mask,0.25);

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

LARGE_PENALTY=1;

dataCost = ones( NUM_OF_UNK, NUM_OF_LABEL );

% 
% E( FG ) = BG
dataCost( fg_mask1d,FG_LID)=0;
dataCost(~fg_mask1d,FG_LID)=LARGE_PENALTY;

% E( BG ) = FG
dataCost( fg_mask1d,BG_LID)=LARGE_PENALTY; 
dataCost(~fg_mask1d,BG_LID)=LARGE_PENALTY;

%% setup Pairwised cost
 
fg_gxy6d = getImgGXY6D(fg);


fg_1d = double(reshape(fg,[],3));
bg_1d = double(reshape(bg,[],3));

pairCost = zeros(size(fg,1),size(fg,2));

[uu,vv]=find(nnG);        

weiNNG = nnG;

for i=1:numel(uu)
    
    pIdx = uu(i);
    qIdx = vv(i);
    
    xi = norm( fg_1d(pIdx,:)- bg_1d(qIdx,:) ); 
    weiNNG(pIdx,qIdx)=xi;
end


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

GCO_SetDataCost(h, dataCost' );

%GCO_SetSmoothCost(h,[0,1;
%                     1,0]);

GCO_SetNeighbors(h, weiNNG );

GCO_Expansion(h);   

ll = GCO_GetLabeling(h);


ll2d=reshape(ll, size(fg_mask));
figure;
imshow(ll2d,colorcube(10));






















