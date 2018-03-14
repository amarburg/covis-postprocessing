function [vg,v_filtg,vrg,wg,stdg,covarg] = l3grid_doppler(x,y,z,v,v_filt,vr,std,covar,xg,yg,zg,vg,v_filtg,vrg,wg,stdg,covarg)

% x = xv;
% y = yv;
% z = zv;
% v = vz;
% v_filt = vr_filt;
% std = vr_std;
% xg = grd.x;
% yg = grd.y;
% zg = grd.z;
% vg = grd.v;
% v_filtg = grd.v_filt;
% vrg = grd.vr;
% wg = grd.w;
% stdg = grd.std;
% covarg = grd.covar;
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
% ---
% Version 1.0 - cjones@apl.washington.edu 06/2010
% Version 1.1 - xupeng_66@hotmail.com 05/2011
% Version 1.2 - xupeng_66@hotmail.com 06/2011 (adding a grid for the radial
% velocity vr)
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
v_filt=v_filt(ii);
std=std(ii); % radial velocity standard deviation
vr=vr(ii); % radial velocity
covar = covar(ii); % covariance function

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
         vg(p)=vg(p)+w.*v(:); % pseudo vertical velocity
         v_filtg(p)=v_filtg(p)+w.*v_filt(:); % filtered pseudo vertical velocity
         stdg(p)=stdg(p)+w.*std(:); % gridded radial velocity standard deviation
         covarg(p) = covarg(p)+w.*covar(:); % gridded covariance function
         vrg(p)=vrg(p)+w.*vr(:); % radial velocity
         wg(p)=wg(p)+w; % gridding weight
      end
   end
end

end
