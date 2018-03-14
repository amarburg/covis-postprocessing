function [vr,vr_filt,rc,I_av,I_filt,vr_std,I_std,covarsum] = covis_incoher_dop_xgy(hdr, dsp, range, data_burst)
%
% Coherent average of all input pings in burst is
% subtracted from all pings to reduce ground return through sidelobes.
%
% This function takes in beamformed data for one burst,
% and processes it into a 2D radial velocity slice,
% averaging over all pings in burst.
%
% output:
% vr is the mean radial velocity calculated using the covariance method
% vr_filt is the filtered radial velocity;
% rc is the radial distance
% I_av is the mean backscatter cross-section calculated over all the pings within the burst
% I_filter is the filtered backscatter cross-section
% vr_std is the standard deviation of the radial velocity estimation.
% I_std is the standard deviation of the backscatter cross-section estimation.
% covarsum is the covariance function averaged over all the pings.
%---------------------------------------------------------------------
% versions - 
%  drj@apl.washington.edu
%  Edited 8/25/2010 by cjones@apl.washington.edu 
%  Edited 10/4/2010 by drj@apl


cor = dsp.correlation;

% correlation range window size [number of samples]
if(~isfield(cor,'window_size'))
    cor.window_size = 0.001;
end
window_size = cor.window_size;

% correlation window overlap [number of samples]
if(~isfield(cor,'window_overlap'))
    cor.window_overlap = 0.4;
end
overlap = cor.window_overlap;

% Threshold for windowing image, units vol. scat. cross section
windthresh = cor.windthresh;

sound_speed = hdr.sound_speed;
frequency = hdr.xmit_freq;
fsamp = hdr.sample_rate;
pulse_width = hdr.pulse_width;

nwindow = round(window_size*fsamp);
noverlap = round(overlap*nwindow);
average = mean(data_burst,3);

% % Loops on bursts
% I1 =zeros(size(data_burst));
% covar = zeros(size(data_burst));
% thetai=zeros(size(data_burst));

% Applying the new subtraction scheme developed by C. Jones to remove
% contribution from the edifice in the VSS measurements. 
if(strfind(dsp.ping_combination.mode,'diff'))
    data_burst = 0.707*diff(data_burst,1,3);
end
covar = zeros(0);
I1 = zeros(0);
thetai = zeros(0);
for np = 1:size(data_burst,3)
    
%     if(strfind(dsp.ping_combination.mode,'diff'))
%         % Subtract average to reduce the contribution from the chimney
%         sig_ping(:,:) = data_burst(:,:,np) - average;
%     else
%         sig_ping(:,:) = data_burst(:,:,np);
%     end
   sig_ping(:,:) = data_burst(:,:,np);
    
    % Window in range
    [I1(:,:,np),~] = mag2_win(sig_ping,range,nwindow,noverlap);
    [covar(:,:,np),rc] = autocovar_win(sig_ping,range,nwindow,noverlap);
    thetai(:,:,np)=angle(covar(:,:,np));
end    % End loop on np
I_av=sum(I1,3)/size(data_burst,3);
covarsum=sum(covar,3);
thetac = angle(covarsum);
%thetac=imag(covarsum)./real(covarsum);
theta_std=std(thetai,0,3); % calculate the standard deviation of the angular frequency estimation
theta_m = mean(thetai,3); % calculate the mean of te angular frequency estimation
vr_cm_s_vel = 100*sound_speed*fsamp/(4*pi*frequency)*theta_m/8; % velocity ping-averaged radial velocity
I_std=std(I1,0,3); % calculate the standard deviation of the back scatter intensity
vr_cm_s = 100*sound_speed*fsamp/(4*pi*frequency)*thetac/8; % covariance ping-averaged radial velocity
vr_std=100*sound_speed*fsamp/(4*pi*frequency)*theta_std/8; % standard deviation of radial velocity
% truncate the result to include only the above threshold back sacttering
% intensity.
window = 1 - exp(-(I_av/windthresh+0.0001).^4);
I_filt=I_av.*window;
%vr_filt = vr_cm_s.*window;
vr=vr_cm_s;
vr_filt = vr_cm_s_vel;
vr_std = vr_std/sqrt(2); % the factor sqrt(2) accounts for the average between two bursts at a declination angle.
I_std=I_std/sqrt(2);
end

%--------------------------------------------------------------------------
function [covar,rc]=autocovar_win(z,r,window,overlap)
%
%   Average over a window of the unit-lag
%   autocovariance of a complex series.
%
%   INPUTS:
%      z = complex series
%      r = range vector
%      window = window (number of samples)
%      overlap = window overlap (number of samples)
%   option = 'unbiased', 'biased', or 'coeff'
%
%   OUTPUT:
%	covar = Unit-lag covariance
%	rc = positions of thetc values (m)

[N,M]=size(z);
nbins=floor(N/(window-overlap));
covar=zeros(nbins,M);
coeff=zeros(nbins,M);
rc=zeros(nbins,1);
for m=1:nbins
    j=(m-1)*(window-overlap)+1;
    k=j+window-1;
    
    if j < 1
        j = 1;
    end
    if k>N-8
        k=N-8;
    end
    if j > k
        j = k;
    end
    
    i=j:k;
    covar(m,:)=mean(z(i,:).*conj(z(i+8,:)));
    rc(m)=mean(r(i));
    
end

end


%--------------------------------------------------------------------------
function [zm,rc]=mag2_win(z,r,window,overlap)
%
%   Average over a window of the magnitude squared of a complex series
%
%   INPUTS:
%      z = complex series
%      r = range vector
%      window = window (number of samples)
%      overlap = window overlap (number of samples)
%   option = 'unbiased', 'biased', or 'coeff'
%
%   OUTPUT:
%	zm = window averaged magnitude squared of z
%	rc = positions of wabs values (m)

[N,M]=size(z);
nbins=floor(N/(window-overlap));
zm=zeros(nbins,M);
rc=zeros(nbins,1);
for m=1:nbins
    j=(m-1)*(window-overlap)+1;
    k=j+window-1;
    
    if j < 1
        j = 1;
    end
    if k>N
        k=N;
    end
    if j > k
        j = k;
    end
    
    i=j:k;
    zm(m,:)=mean(abs(z(i,:).^2));
    if k <= N
        rc(m)=mean(r(i));
    else
        rc(m)=r(N);
    end
    
end

end


