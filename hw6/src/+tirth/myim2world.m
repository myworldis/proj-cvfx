function [ pts3 ] = myim2world( imx,imy,zval, invP )

wpts=[imx,imy,zval];

dep = zval;

xyz_im = [wpts(1)*dep , wpts(2)*dep , dep ,1];

pts3d_xyzw=(invP*xyz_im')';
pts3d_xyzw=pts3d_xyzw./pts3d_xyzw(4);
 
pts3=pts3d_xyzw(1:3);

end

