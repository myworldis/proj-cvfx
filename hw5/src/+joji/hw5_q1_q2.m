clear;
clc;
%hw5_setup

%% read image
Ia = imread('image1.jpg');
Ib = imread('image11.jpg');

%% show image pair
%figure(1) ; clf ;
%imagesc(cat(2, Ia, Ib)); %兩張圖並排顯示　
%axis image off ;
%vl_demo_print('sift_match_1', 1) ;

%% image composite
I1 = rgb2gray(Ia);
I2 = rgb2gray(Ib);
Ic(:,:,1)=I1;
Ic(:,:,2)=I2;
Ic(:,:,3)=I2;
%imwrite(Ic,'image_composite.png');
%imshow(Ic);

%% find feature
[fa,da] = vl_sift(im2single(rgb2gray(Ia)));
[fb,db] = vl_sift(im2single(rgb2gray(Ib)));

%% plot feature point
%figure(2); clf;
%imagesc(Ia); 
%vl_plotframe(fa(:,9000:12308)); % find_feature_fa.png
%vl_plotframe(fb(:,2350:3440)); % find_feature_fa.png
%axis image off ;

%% matching
[matches, scores] = vl_ubcmatch(da,db);
[drop, perm] = sort(scores, 'descend'); %drop: sort之後的score, perm: sort之前的score
% perm紀錄: score由大到小, match的編號   
matches = matches(:, perm); %把match的編號, 依照perm重新排序
scores  = scores(perm); %同上

%% plot matching result
figure(3); clf;
imagesc(cat(2, Ia, Ib));
%imagesc(Ic);

xa = fa(1,matches(1,:));
xb = fb(1,matches(2,:))+ size(Ia,2);
%xb = fb(1,matches(2,:));
ya = fa(2,matches(1,:));
yb = fb(2,matches(2,:));
%yb = fb(2,matches(2,1:300));

hold on ;
h = line([xa ; xb], [ya ; yb]);
set(h,'linewidth', 1, 'color', 'b');
axis image off ;

%% plot matching point
vl_plotframe(fa(:,matches(1,:))) ;
fb(1,:) = fb(1,:) + size(Ia,2) ;
vl_plotframe(fb(:,matches(2,:))) ;
axis image off ;
vl_demo_print('sift_match_2', 1);





