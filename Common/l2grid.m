function [vg,wg] = l2grid(x,y,v,xg,yg,vg,wg)
%
% [vg,wg]=l3grid(x,y,v,xg,yg,vg,wg) grids the values in v with 
% coordinates (x,y,z) onto a uniform 2-D grid (xg,yg) using 
% nearest-neighbor linear interpolation.      
% The positions (x,y) may be non-uniform and non-monotinic data.  
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

[Ny,Nx]=size(xg);
dx=abs(xg(1,2)-xg(1,1));
dy=abs(yg(2,1)-yg(1,1));

xg=xg(:);
yg=yg(:);

xmin=min(xg);
ymin=min(yg);
xmax=max(xg);
ymax=max(yg);

% use only points within the grid
ii=find(x>=xmin & x<=xmax & y>=ymin & y<=ymax & isfinite(v) & isfinite(x));
if(isempty(ii))
   return;
end
x=x(ii);
y=y(ii);
v=v(ii);

i(:,1)=floor((x(:)-xmin)/dx)+1;
i(:,2)=ceil((x(:)-xmin)/dx)+1;
j(:,1)=floor((y(:)-ymin)/dy)+1;
j(:,2)=ceil((y(:)-ymin)/dy)+1;

for n=1:2
   wx=1-abs(xg(i(:,n))-x(:))/dx;
   for m=1:2
      wy=1-abs(yg(j(:,m))-y(:))/dy;
      w=sqrt(wx.^2+wy.^2);
      k=sub2ind([Ny,Nx],j(:,n),i(:,m));
      vg(k)=vg(k)+w.*v(:);
      wg(k)=wg(k)+w;
   end
end

%ii=find(wg);
%vg(ii)=vg(ii).*wg(ii);

%m=sub2ind([Nx,Ny],[i1;i1;i2;i2],[j1;j2;j1;j2]);
%wx1=1-abs(xg(i1)-x(:))/dx;
%wx2=1-abs(xg(i2)-x(:))/dx;
%wy1=1-abs(yg(j1)-y(:))/dy;
%wy2=1-abs(yg(j2)-y(:))/dy;
%w(:,1)=sqrt(wx1.^2+wy1.^2);
%w(:,2)=sqrt(wx1.^2+wy2.^2);
%w(:,3)=sqrt(wx2.^2+wy1.^2);
%w(:,4)=sqrt(wx2.^2+wy2.^2);
%vg(m)=vg(m)+w.*(ones(4,1)*v(:));



