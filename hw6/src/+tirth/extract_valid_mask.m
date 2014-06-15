function [eff_flag ] = extract_valid_mask( objmap , rep2d , im_size )
% [eff_pts2d_flag ] = extract_valid_mask( objmap , rep2d , im_size )
%

if nargin <3
    error('invalid');
end

PH=im_size(1);
PW=im_size(2);

eff_flag = false(size(rep2d,1),1);

for k=1:size(rep2d,1)  
    
    xy=round([rep2d(k,1),rep2d(k,2)]); 
    
    if xy(1) > 0 && xy(1) < PW && xy(2) > 0 && xy(2) < PH 
       % valid point
       xx=xy(1);
       yy=xy(2);
       
       if objmap(yy,xx) 
          eff_flag(k)=true;
       end
       
    end    
end 


end

