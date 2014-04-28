

cd('D:\nthu_school\CVFX\proj-cvfx\hw4\src');

addpath('../lib/GCMex');

dataPath = '../data/face';


mask = imread( fullfile( dataPath , 'mask.png' ) );

s1 = imread( fullfile( dataPath , 's1.png' ) );
s2 = imread( fullfile( dataPath , 's2.png') );

fimshowpair(s1,s2);


%%

data_penalty_E0=@(x)0;
data_penalty_E1=@(x)1;

pairwise_E00=@(x,y);
pairwise_E01=@(x,y);
pairwise_E11=@(x,y);
pairwise_E10=@(x,y);


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


h = GCO_Create(4,3); 





























