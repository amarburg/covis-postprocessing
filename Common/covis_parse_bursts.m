function [ burst ] = covis_parse_bursts( png )
%
%  COVIS_PARSE_BURSTS
%
%  This function searches through a list of pings and find the 
%  consequtive pings that have the same elevation value.  Each set of
%  consequtive pings in called a burst.
%  The input 'png' must be an array of covis ping structures.
%  The output is an array of covis burst structures with the firlds: 
%   burst.elev = elevation angle of burst
%   burst.npings = number of pings in burst
%   burst.start_ping = start ping number in burst
%
% ----------
% Version 1.0 - cjones@apl.washington.edu 10/2010

global Verbose;

total_npings = length(png);
nbursts = 1;
npings = 1;
start_ping = 1;
prev_elev = png(1).tcm.kPAngle;

for n = 2:total_npings

    % check for elevation change
    elev = png(n).tcm.kPAngle;

    if(elev == prev_elev) % still within the current burst
        npings = npings + 1;
    else % new burst
        burst(nbursts).elev = prev_elev; % save elev
        burst(nbursts).npings = npings;  % save ping count
        burst(nbursts).start_ping = start_ping; % start ping
        if(Verbose > 1)
            fprintf('Burst %d: elev=%f, npings=%d, start_ping=%d\n', ...
                nbursts, burst(nbursts).elev, burst(nbursts).npings, ...
                burst(nbursts).start_ping);
        end
        nbursts = nbursts + 1;
        start_ping = n; % save the ping start for the next burst
        npings = 1; % reset ping count
    end
    
    prev_elev = elev;

end

end

