function [cor,I,rc] = covis_cor_win(a,b,r,window,overlap)
%   Fixed window size cross correlation of two complex series
%
%   INPUTS:
%      a,b = complex series
%      r = range vector
%      window = window size (number of samples)
%      overlap = window overlap size (number of samples)
%
%   outputs:
%      rc = bin range
%      cor = corrleation
%      I = average intensity
%

[N,M]=size(a);
nbins=floor(N/(window-overlap));
cab=a.*conj(b);
cor=zeros(nbins,M);
I=zeros(nbins,M);
rc=zeros(nbins,1);
for m=1:nbins
    j=(m-1)*(window-overlap)+1;
    k=j+window-1;
    if (k>N) k=N; end
    i=j:k;
    cor(m,:)=sum(cab(i,:))/window;
    I(m,:) = sqrt(sum(abs(a(i,:)).^2).*sum(abs(b(i,:)).^2))/window;
    cor(m,:) = cor(m,:)./I(m,:);
    rc(m)=mean(r(i));
end

end





