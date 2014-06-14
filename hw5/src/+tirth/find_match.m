function [ pts1,pts2 ] = find_match( fim1,fim2 )
%
%  [ pts1,pts2 ] = find_match( fim1,fim2 )
%  
%
if nargin < 2
    error('invalid');
end


fim1=im2single(rgb2gray(fim1));
fim2=im2single(rgb2gray(fim2));



% 128 x N_features
[f1,d1] = vl_sift(fim1) ;
[f2,d2] = vl_sift(fim2) ;


%%


    [matches, scores] = vl_ubcmatch(d1,d2) ;

    numMatches = size(matches,2) ;

    pts1 = f1(1:2,matches(1,:))' ; 
    pts2 = f2(1:2,matches(2,:))' ; 
    fprintf('vl_ubcmatch , found %d matching\n', (numMatches) );
    
    return;



%% matching f1 and f2
%
% D = pdist2(X,Y,distance,'Smallest',K) returns a K-by-my matrix D 
% containing the K smallest pairwise distances to observations in X for 
% each observation in Y. pdist2 sorts the distances in each column of D 
% in ascending order. D = pdist2(X,Y,distance,'Largest',K) returns the K 
% largest pairwise distances sorted in descending order. If K is greater 
% than mx, pdist2 returns an mx-by-my distance matrix. For each observation in Y,
% pdist2 finds the K smallest or largest distances by computing and comparing the 
% distance values to all the observations in X. 
%  

[mD2D1_dist,mD1_idx_d2]=pdist2(double(d1'),double(d2'),'euclidean','Smallest',1);

[mD1D2_dist,mD2_idx_d1]=pdist2(double(d2'),double(d1'),'euclidean','Smallest',1);

mth_1=median(mD2D1_dist);

effFlag = mD2D1_dist < mth_1*5;

s_MatchD2D1_dist=mD2D1_dist(effFlag);
s_mD1_idx_d2 =mD1_idx_d2(effFlag);
s_D2_idx = find(effFlag);

mth_2=median(mD1D2_dist);  
effFlag2 = mD1D2_dist < mth_2*5;

s_MatchD1D2_dist=mD1D2_dist(effFlag2);
s_mD2_idx_d1 =mD2_idx_d1(effFlag2);
s_D1_idx =mD2_idx_d1(effFlag2);

% find bi-direction matching
bim_d1_d2=[];


for i=1:numel(s_D2_idx)
   
    d2_idx = s_D2_idx(i);
    mD1_idx = s_mD1_idx_d2(i);
    
    if~isempty(s_D1_idx==mD1_idx)
    
        mD2_idx = s_mD2_idx_d1(s_D1_idx==mD1_idx);
        
        if mD2_idx == d2_idx 
            % found a bi-direction matching
            bim_d1_d2=cat(1,bim_d1_d2,[mD1_idx,d2_idx]);
        end     
        
    end% if     
    
end% loop



if numel(bim_d1_d2) > 10

    if 0
        fimshowpair(fim1,fim2);
        hold on;
        plot(f1(1,bim_d1_d2(:,1))',f1(2,bim_d1_d2(:,1))','x','markersize',13,'linewidth',2);
        plot(f2(1,bim_d1_d2(:,2))'+size(fim1,2),f2(2,bim_d1_d2(:,2))','x','markersize',13,'linewidth',2);

        for k=1:size(bim_d1_d2,1)

           xy=[f1(1,bim_d1_d2(k,1))',f1(2,bim_d1_d2(k,1))';
               f2(1,bim_d1_d2(k,1))'+size(fim1,2),f2(2,bim_d1_d2(k,1))'; 
           ];

           plot(xy(:,1),xy(:,2),'linewidth',1,'color','r');
           hold on;
        end
    end

    pts1= [f1(1,bim_d1_d2(:,1))',f1(2,bim_d1_d2(:,1))'];
    pts2= [f2(1,bim_d1_d2(:,1))',f2(2,bim_d1_d2(:,1))'];

    fprintf('bi-matching , found %d matching\n',numel(bim_d1_d2));
else 
    
    %fnum=1000;
    
    %pts1= [f1(1,s_D1_idx(1:fnum))',f1(2,s_D1_idx(1:fnum))'];
    %pts2= [f2(1,s_D2_idx(1:fnum))',f2(2,s_D2_idx(1:fnum))'];

    %pts1= [f1(1,(1:fnum))',f1(2,(1:fnum))'];
    %pts2= [f2(1,(1:fnum))',f2(2,(1:fnum))'];
    

    [matches, scores] = vl_ubcmatch(d1,d2) ;

    numMatches = size(matches,2) ;

    pts1 = f1(1:2,matches(1,:))' ; 
    pts2 = f2(1:2,matches(2,:))' ; 
    fprintf('vl_ubcmatch , found %d matching\n', (numMatches) );
end


end

