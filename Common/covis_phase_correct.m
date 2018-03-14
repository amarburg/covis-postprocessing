function  data2_corr = covis_phase_correct(ping, data1, data2)
%
% Corrects phase jitter of data2 by comparing
% monitor signals.  
% 
% drj@apl.washington.edu 29 July 2010

nsamp = size(data1,1);
nchan = size(data1,2);

sample_rate = ping.hdr.sample_rate;
pulse_width = ping.hdr.pulse_width;

% Number of samples to keep from monitor channel
nkeep = round(3*sample_rate*pulse_width);

% The monitor channel is the last channel
monitor1 = data1(1:nkeep,nchan);
monitor2 = data2(1:nkeep,nchan);

% Cross-correlate monitor signals to determine phase jitter
phase_jitter = angle(sum(monitor2.*conj(monitor1)));

% Correct phase of data2 to agree with data1
data2_corr = exp(-1i*phase_jitter)*data2;

