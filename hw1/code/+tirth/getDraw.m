function [ fgMask ] = getDraw( visbk )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

figure;                 
F=imshow(visbk);        

userDraw(F);            

p=input('pass any to conti');

shot_ori = getframe;
shot_ori = shot_ori.cdata;
udlog=get(F,'userData');
close all;

% channel 3 is the brush channel
figure(5);
imshow(zeros(size(visbk)),'border','tight');
hold on;
% {0:bg, 1:fg, 2:probably-bg, 3:probably-fg}

for i=1:numel(udlog.fg)
    xxyy=udlog.fg{i};
    line(xxyy(:,1)',xxyy(:,2)', 'color', [0,0,1], 'LineWidth', 2);%, 'hittest', 'on'); %turning     hittset off allows you to draw new lines that start on top of an existing line.
end
f=getframe;
f=f.cdata;

fgMask = f(:,:,3)>0;


end

