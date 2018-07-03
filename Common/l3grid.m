function [vg,wg] = l3grid(x,y,z,v,xg,yg,zg,vg,wg)
% 
% [vg,wg]=l3grid(x,y,z,v,xg,yg,zg,vg,wg)
% Grids the values in v with coordinates (x,y,z) onto a uniform 
% 3-D grid (xg,yg,zg) using nearest-neighbor linear interpolation. 
% Data is interpolated onto the neighboring grid cell only. 
% The positions (x,y,z) may be non-uniform and non-monotinic data.  
% Interpolation is done using a linear weighting matrix.
% An updated weighting matrix is returned after each call, 
% so the function can be called multiple time on the same grid, 
% adding new data to the grid on each call. 
% After the final call, the gidded data should be normalized 
% by the weighting matrix, like this
%   n=find(wg); Ig(n)=Ig(n)./wg(n);
%
% ----------
% This program is free software distributed in the hope that it will be useful, 
% but WITHOUT ANY WARRANTY. You can redistribute it and/or modify it.
% Any modifications of the original software must be distributed in such a 
% manner as to avoid any confusion with the original work.
% 
% Please acknowledge the use of this software in any publications arising  
% from research that uses it.
% 
% ----------
% Version 1.0 - cjones@apl.washington.edu 06/2010
%

global Verbose

[Ny,Nx,Nz]=size(xg);

%if(Ny==1)
%nd

dy = abs(yg(2,1,1)-yg(1,1,1));
dx = abs(xg(1,2,1)-xg(1,1,1));
dz = abs(zg(1,1,2)-zg(1,1,1));

xg=xg(:);
yg=yg(:);
zg=zg(:);

xmin=min(xg);
ymin=min(yg);
zmin=min(zg);
xmax=max(xg);
ymax=max(yg);
zmax=max(zg);

% use only finite points within the grid
ii=find(isfinite(v)&(x>=xmin)&(x<=xmax)&(y>=ymin)&(y<=ymax)&(z>=zmin)&(z<=zmax));

if(~isempty(ii))

x=x(ii);
y=y(ii);
z=z(ii);
v=v(ii);

i(:,1)=floor((x(:)-xmin)/dx)+1;
i(:,2)=ceil((x(:)-xmin)/dx)+1;
j(:,1)=floor((y(:)-ymin)/dy)+1;
j(:,2)=ceil((y(:)-ymin)/dy)+1;
k(:,1)=floor((z(:)-zmin)/dz)+1;
k(:,2)=ceil((z(:)-zmin)/dz)+1;

for n=1:2
   wx=1-abs(xg(i(:,n))-x(:))/dx;
   for m=1:2
      wy=1-abs(yg(j(:,m))-y(:))/dy;
      for l=1:2
         wz=1-abs(zg(k(:,l))-z(:))/dz;
         w=sqrt(wx.^2+wy.^2+wz.^2);
         p=sub2ind([Ny,Nx,Nz],j(:,m),i(:,n),k(:,l));
         vg(p)=vg(p)+w.*v(:);
         wg(p)=wg(p)+w;
      end
   end
end

end

