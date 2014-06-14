%
%
%
%
%

setup
r_inputPath = fullfile(gdef.dataroot,'IMG_0789_480rr.avi');

vobj = tirth.VideoProxy(); 
vobj.load(r_inputPath);

 
 
%% -- estimateGeometricTransform

outFName='full_vres.avi';
vout = VideoWriter(outFName);  
vout.open();

verbase =1;
TOTAL_FRAME=vobj.totalFrame();

ib=2;
iend=ib+10;
 
all_St={};
all_smooth_txtyrads=[];


vout.writeVideo(vobj.getFrame(1));

NUM_K = 6;
    
for it=ib:iend
    
    fid = it;
    
    % backward
    all_h={};
    
    
    fim_t=vobj.getFrame(fid);
    
    
    for ii=fid-1:-1:fid-NUM_K
        
        if ii < 1
            break; % reach first frame
        end
        
        fim_i=vobj.getFrame(ii);
        [pts1,pts2]=tirth.find_match(fim_t,fim_i);
        
        h_2to1=tirth.estimate_tx(pts2,pts1);
        
        all_h{end+1}=struct;
        all_h{end}.h = h_2to1;
        all_h{end}.dst_fid = ii;
    end
    
    % forward
    for ii=fid+1:1:fid+NUM_K
        
        if ii > TOTAL_FRAME
            break; % reach last frame
        end
        
        fim_i=vobj.getFrame(ii);
        [pts1,pts2]=tirth.find_match(fim_t,fim_i);
        
        h_2to1=tirth.estimate_tx(pts2,pts1);
        
        all_h{end+1}=struct;
        all_h{end}.h = h_2to1;
        all_h{end}.dst_fid = ii;
    end
    
    disp('done');
    
    
    %% approximate S_t
    
    % collect all H
    
    % gaussian
    G=gausswin(NUM_K*2);
    
    
    mid_vidx = NUM_K+1;
    
    all_txtyrads=[];
    all_fid=[];
    
    smooth_txtyrads=[0,0,0,0];
    smooth_weight=[];
    
    for ii=1:numel(all_h);
        
        if all_h{ii}.dst_fid < fid
            gidx = all_h{ii}.dst_fid - fid + mid_vidx;
        else
            % later frame
            gidx = all_h{ii}.dst_fid - fid + mid_vidx - 1;
        end
        
        
        tx=all_h{ii}.h(1,3);
        ty=all_h{ii}.h(2,3);
        
        Hts=all_h{ii}.h';
        
        R = Hts(1:2,1:2);
        % Compute theta from mean of two possible arctangents
        theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
        
        % Compute scale from mean of two stable mean calculations
        scale = mean(R([1 4])/cos(theta));
        
        % G smooth
        smooth_txtyrads(1) = smooth_txtyrads(1) + tx*G(gidx);
        smooth_txtyrads(2) = smooth_txtyrads(2) + ty*G(gidx);
        smooth_txtyrads(3) = smooth_txtyrads(3) + theta*G(gidx);
        smooth_txtyrads(4) = smooth_txtyrads(4) + scale*G(gidx);
        
        smooth_weight(end+1)=G(gidx);
        
        % save
        all_fid(end+1)=all_h{ii}.dst_fid;
        all_txtyrads=cat(1,all_txtyrads,[tx,ty,theta,scale]);
    end
    
    
    % result smoothed h
    sw = sum( smooth_weight );
    smooth_txtyrads = smooth_txtyrads ./ sw;
    
    St = eye(3);
    St(1,3)=smooth_txtyrads(1);
    St(2,3)=smooth_txtyrads(2);
    
    th = smooth_txtyrads(3);
    scal = smooth_txtyrads(4);
    
    R = scal*[ cos(th) ,   sin(th);
        -sin(th) ,  cos(th); ];
    
    St(1:2,1:2)=R;
    
    
    %% vis
    if 0
        [~,sidx]=sort(all_fid);
        
        sort_txtyrads=all_txtyrads(sidx,:);
        figure;
        plot(1:size(sort_txtyrads,1),sort_txtyrads(:,1),'linewidth',1.5,'color','r'); hold on;
        plot(1:size(sort_txtyrads,1),sort_txtyrads(:,2),'linewidth',1.5,'color','g'); hold on;
        plot(1:size(sort_txtyrads,1),sort_txtyrads(:,4),'linewidth',1.5,'color','c'); hold on;
        
        plot(size(sort_txtyrads,1)/2,smooth_txtyrads(1),'+');
        plot(size(sort_txtyrads,1)/2,smooth_txtyrads(2),'+');
        
        legend('tx','ty','scale','sx','sy');
        
        %axis equal;grid on;
        
        figure;
        plot(1:size(sort_txtyrads,1),sort_txtyrads(:,3),'linewidth',2,'color','b'); hold on;
        legend('rad');
        axis equal;grid on;
    end
    
    %% save
    
      
    all_St{end+1}=St;
    all_smooth_txtyrads=cat(1,all_smooth_txtyrads,smooth_txtyrads);
    
    
    %% stablization
    
    % Tx:2x3
    assert(St(3,1)==0);
    dst = cv.warpAffine( fim_t, St(1:2,:));
    
    
    comp=cat(2,fim_t,dst);
    
    vout.writeVideo(comp);
    %fimshowpair(fim_t,dst);
    
    fprintf('pass frame.%d\n;',it);
    
end


vout.close();

disp('ALL DONE');

%%

figure;
plot(1:size(all_smooth_txtyrads,1),all_smooth_txtyrads(:,1),'r'); hold on;
plot(1:size(all_smooth_txtyrads,1),all_smooth_txtyrads(:,2),'b');
title('num=6');

%% global inpainting by mosaicing

for ii=1:numel(all_h)
    
    ti_to_src = inv(all_h{ii}.h);
    
    
end


%% 
fimshow(fim2);hold on;
plot(pts1(:,1),pts1(:,2),'+','markersize',13);
plot(pts2(:,1),pts2(:,2),'x','markersize',13,'color','r');

pts2_h = cat(2,pts2,ones(size(pts2,1),1));

pts2_tx=pts2_h*hmat;


plot(pts2_tx(:,1),pts2_tx(:,2),'+','markersize',13,'color','g');

imgBp_smo = imwarp(ori_frame_k, tform, 'OutputView', imref2d(size(ori_frame_k)));
fimshowpair(fim_t,imgBp_smo);


%%
















