function data_out = covis_calibration(data_in, bfm, ping, calibrate)

% Function to preprocess Reson  SeaBat data
% after beamforming to provide baseband time series
% normalized such that 10*log10(<envelope^2>) equals
% either volume scattering strength (VSS) or target strength (TS).
% In the volume scattering case, it is assumed that the
% fan-beam projector is used, while, in the target strength
% case, it is assumed that the wide-beam projector is used.
% cal_mode must be either 'VSS' or 'TS'

% The inputs are found by:
% Reading ping meta data fson file
%  json_file = sprintf('rec_7000_%06d.json',ping_num);
%  json_str = fileread([swp_path json_file]);
%  json = parse_json(json_str);
%  ping.hdr = json.hdr;
% Reading raw ping data:
%  [hdr,data] = covis_read(file);
%
% ---
% Edited
% - Darrell Jackson, 1 March 2010.
% - cjones@apl - 4 June 2010 - changed input args
% - Darrell Jackson, 6 July 2010
% Edited 7/22/2010 by drj to include VSS and TS calibration modes.
% - drj@apl - 18 August 2010 Corrected errors in both modesfm input to
% - drj@apl - 2 September 2010, appended corrected version of
% linear_interp.m
% - expanded calibration arguments to include filtering, 9/23/2010, drj@apl
% Edited 10/2010 cjones@apl
% - matlab interp1 instead of linear_interp
% - faster matrix multiplies
%

% The following inputs are part of the structure "ping":
f = ping.hdr.xmit_freq;         % xmit freq (hz)
tau = ping.hdr.pulse_width;     % Pulse length (sec)
sls = ping.hdr.power_sel;       % source level setting (dB)
c = ping.hdr.sound_speed;       % m/s
fsamp = ping.hdr.sample_rate;   % Complex sampling frequency (Hz)
gain = ping.hdr.gain_sel;       % gain (dB)

% The beamformer angles and ranges are taken from "swp"
theta_bfm = bfm.angle;   % radians
range = bfm.range;

cal_mode = calibrate.mode; % 'VSS' or 'TS'

% Attenuation (Francois-Garrison, with z = 2500, S = 35, T = 2, pH = 7)
if f == 200000
    alpha = 8.8/1000;
elseif f == 396000
    alpha = 34.6/1000;
else
    alpha = 0;
    disp('Attenuation set to 0, as frequency is not one of two assumed values')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fixed calibration parameters

switch(cal_mode)
    
    case('VSS')
        
        if f ~= 396000
            error('VSS calibration only available at 396 kHz');
        end
        
        % Beam pattern for fan-beam transmitter, units are dB normalized
        % to 1 at boresight, and negative if response is less than at boresight,
        % which is the direction in which source level is measured.
        
        xmit = load('TC2160_Horizontal_Beam_396kHz.txt');
        
        % Change ram angles to angles appropriate to beam patterns
        ram_angles = xmit(:,1);
        na = find(ram_angles > 180);
        ram_angles(na) = ram_angles(na) - 360;        
        %for na = 1:length(ram_angles)
        %    if ram_angles(na) > 180
        %        ram_angles(na) = ram_angles(na) - 360;
        %    end
        %end
        
        theta_deg = -ram_angles;
        theta = pi/180*theta_deg;
        
        % Interpolate beam pattern
        %xmit_patt = linear_interp(theta,xmit(:,2),theta_bfm);
        xmit_patt = interp1(theta,xmit(:,2),theta_bfm);
        
        % Source level table, giving source level setting and source level
        % corrected for attenuation, which is 0.2 dB at 6 m, 396 kHz
        
        %sl_table = [200 , 199.6+0.2;
        %            205 , 204.5+0.2;
        %            210	, 209.1+0.2;
        %            215	, 213.5+0.2;
        %            220	, 216.9+0.2];
        % Extended SL table to accomodate Shilshole data having sl setting 180
        sl_table = [180 , 180
            200 , 199.6+0.2;
            205 , 204.5+0.2;
            210	, 209.1+0.2;
            215	, 213.5+0.2;
            220	, 216.9+0.2];
        
        % interpolate source level setting to get source level
        %sl = linear_interp(sl_table(:,1), sl_table(:,2), sls);
        sl = interp1(sl_table(:,1), sl_table(:,2), sls);
        
        % Transmit 3-dB vertical full beamwidth (deg)
        theta_vr = 1.03;
        % Convert to radians
        theta_vr = pi*theta_vr/180;
        % Convert to integrated beamwidth (rad) using Gaussian approximation
        Delta_v = 0.5*sqrt(pi/log(2))*theta_vr;
        
        % Coefficients of polynomial fit to receive sensitivity
        P1 = load('rec_sens_396_poly_coeffs.txt');
        % this form of load assumes an ascii file as input and a
        %   double as output; changing to a mat-file will
        %   break the code by producing a double (kgb 9/27/10)
        % Receive sensitivity for each beam (machine units/ muPa, gain = 0 dB, no
        % TVG)
        beam_nos = [1:256];
        rs = polyval(P1,beam_nos);
        
        % Coefficients of polynomial fit to integrated horizontal beamwidth
        % (reverberation index = rindex)
        P2 = load('rindex_396_poly_coeffs.txt');
        % this form of load assumes an ascii file as input and a
        %   double as output; changing to a mat-file will
        %   break the code by producing a double (kgb 9/27/10)
        % Delta_h = rindex
        Delta_h = polyval(P2,beam_nos);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % The basis for the multiplicative factors to be applied is
        % the sonar equation in the form
        % 20*log10(abs(data_in))=vss+sl+xmit_patt+gain-TL
        %           +20*log10(rs)+10*log10(0.5*c*tau*Delta_v*Delta_h)
        % where vss is the volume scattering strength and TL is the transmission
        % loss, TL = 20*log10(range)+2*alpha*range, incorporating the growth
        % in insonified volume with range.
        % It is assumed that the TVG settings are spreading = 0, attenuation = 0.
        
        % We desire a complex output signal, data_out, such that
        % vss = 20*log10(abs(data_out)).  In actuality,
        % vss = 10*log10(<abs(data_out)^2>) where we have departed from
        % Matlab notation to show the averaging inherent in the
        % definition of vss.  Taking antilogs and removing averaging
        % and absolute value operations, the desired scaling is
        % data_out = data_in/S
        % where S =  rs*sqrt(0.5*c*tau*Delta_v*Delta_h)*10^q
        % q = (sl+xmit_patt+gain-TL)/20
        % This mistreats Matlab matrix notation for the sake of simplicity.
        % Actually, we should regard all factors that depend upon
        % beam number as nbeams x nbeams diagonal matrices,
        % where
        [nsamp,nbeams] = size(data_in);
        
        % Define
        rsinv = 1./rs;
        Delta_hinv = 1./sqrt(Delta_h);
        xmitinv = 10.^(-xmit_patt/20);
        
        % The following diagonal matrix, postmultiplying the matrix data_in,
        % makes all corrections that depend on beam number
        Beam_corr(1,:) = (rsinv.*Delta_hinv.*xmitinv);
        
        % Transmission loss depends on range
        tl = 20*log10(range) + 2*alpha*range;
        % The following diagonal matrix, premultiplying the matrix data_in,
        % makes the tl corrections that depends on sample number (range)
        tl_corr(:,1) = (10.^(tl/20));
        
        % The factors that don't depend upon beam
        % number are collected in
        const = 10^(-(sl+gain)/20)/sqrt(0.5*c*tau*Delta_v);
        
        data_out = const*(tl_corr*Beam_corr).*data_in;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case('TS')
        
        if f == 396000
            % Beam patterns fan-beam transmitter,
            % units are dB normalized
            % to 1 at boresight, and negative if response is less than at boresight,
            % which is the direction in which source level is measured.
            xmit = load('TC2160_Horizontal_Beam_396kHz.txt');
            % Extended SL table to accomodate Shilshole data having sl setting
            % 180. Corrected for attenuation, which is 0.2 dB at 6 m, 396 kHz
            sl_table = [180 , 180
                200 , 199.6+0.2;
                205 , 204.5+0.2;
                210	, 209.1+0.2;
                215	, 213.5+0.2;
                220	, 216.9+0.2];
            % Coefficients of polynomial fit to receive sensitivity
            P1 = load('rec_sens_396_poly_coeffs.txt');
            % this form of load assumes an ascii file as input and a
            %   double as output; changing to a mat-file will
            %   break the code by producing a double (kgb 9/27/10)
            % Receive sensitivity for each beam (machine units/ muPa, gain = 0 dB, no
            % TVG)
            beam_nos = [1:256];
            rs = polyval(P1,beam_nos);
            
        elseif f == 200000
            % Beam patterns broad-beam transmitter
            xmit = load('TC2162_Horizontal_Beam_200kHz.txt');
            % Source level table, giving source level setting and source level
            % corrected for attenuation, which is 0.06 dB at 6 m, 200 kHz
            sl_table = [180	, 180.9+0.06;
                185	, 185.4+0.06;
                190	, 190.3+0.06;
                195	, 194.7+0.06;
                200	, 199.2+0.06;
                205	, 203.5+0.06];
            % Coefficients of polynomial fit to receive sensitivity
            P1 = load('rec_sens_200_poly_coeffs.txt');
            % this form of load assumes an ascii file as input and a
            %   double as output; changing to a mat-file will
            %   break the code by producing a double (kgb 9/27/10)
            % Receive sensitivity for each beam (machine units/ muPa, gain = 0 dB, no
            % TVG)
            beam_nos = [1:128];
            rs = polyval(P1,beam_nos);
        else
            error('TS calibraton only available at 200 and 396 kHz');
        end
        
        % Change ram angles to angles appropriate to beam patterns
        ram_angles = xmit(:,1);
        na = find(ram_angles > 180);
        ram_angles(na) = ram_angles(na) - 360;        
        %for na = 1:length(ram_angles)
        %    if ram_angles(na) > 180
        %        ram_angles(na) = ram_angles(na) - 360;
        %    end
        %end
        
        theta_deg = -ram_angles;
        theta = pi/180*theta_deg;
        
        % Interpolate beam pattern
        %xmit_patt = linear_interp(theta,xmit(:,2),theta_bfm);
        xmit_patt = interp1(theta,xmit(:,2),theta_bfm);
        
        % interpolate source level setting to get source level
        %sl = linear_interp(sl_table(:,1), sl_table(:,2), sls);
        sl = interp1(sl_table(:,1), sl_table(:,2), sls);
        
        % No corrections are made for directivity other than the
        % horizontal transmit pattern
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % The basis for the multiplicative factors to be applied is
        % the sonar equation in the form
        % 20*log10(envelope in machine units) =
        % ts+sl+xmit_patt+gain-TL+20*log10(rs)
        % where ts is the target strength and TL is the transmission
        % loss, TL = 40*log10(range)+2*alpha*range.
        % It is assumed that the TVG settings are spreading = 0, attenuation = 0.
        
        % We desire a complex output signal, data_out, such that
        % ts = 20*log10(abs(data_out)).  Taking antilogs
        % the desired scaling is
        % data_out = data_in/S
        % where S =  rs*10^q
        % q = (sl+xmit_patt+gain-TL)/20
        % This mistreats Matlab matrix notation for the sake of simplicity.
        % Actually, we should regard all factors that depend upon
        % beam number as nbeams x nbeams diagonal matrices,
        % where
        [nsamp,nbeams] = size(data_in);
        
        % Define
        rsinv = 1./rs;
        xmitinv = 10.^(-xmit_patt/20);
        
        % The following diagonal matrix, postmultiplying the matrix data_in,
        % makes all corrections that depend on beam number
        Beam_corr(1,:) = (rsinv.*xmitinv);
        
        % Transmission loss depends on range
        tl = 40*log10(range) + 2*alpha*range;
        % The following diagonal matrix, premultiplying the matrix data_in,
        % makes the tl corrections that depends on sample number (range)
        tl_corr(:,1) = (10.^(tl/20));
        
        % The factor that doesn't depend upon beam number or range is
        const = 10^(-(sl+gain)/20);
        
        data_out = const*(tl_corr*Beam_corr).*data_in;
end

end


function y_out = linear_interp(x_in, y_in, x_out);

% Function to interpolate (linearly) the function y(x) given at
% discrete x-values, x_in.  y_out is the value interpolated for
% the values givin in the vector x_out. The vectors x_in and y_in must have same length,
% and x_out must lie within the limits set by x_in.

if length(x_in) ~= length(y_in)
    error('x- and y- input vectors must have same length');
end

if min(x_out) < min(x_in) | max(x_out) > max(x_in)
    error ('Output x-values must lie between input values');
end

for n2 = 1:length(x_out)
    
    for n = 1:length(x_in)-1
        x_diff = x_out(n2)-x_in(n);
        test = x_diff/abs(x_in(n+1)-x_in(n));
        
        if test == 0
            y1 = y_in(n);
            t1 = 0.0;
            y2 = 0.0;
            t2 = 1.0;
            
        elseif test <= 1 & test > 0  % x_out lies between x_in(n) and x_in(n+1)
            y1 = y_in(n);
            y2 = y_in(n+1);
            t1 = test;
            t2 = 1-t1;
            
        end % End if test == 0
    end % End loop on n
    
    y_out(n2) = t1*y2+t2*y1;
    
end   % End loop on n2

end

