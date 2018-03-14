function [covis] = covis_doppler_sweep(swp_path, swp_name, json_file)

% Grid covis DOPPLER sweep data onto a rectangular grid.
% The inputs to this function are the path to the sweep directory 
% (swp_path) and the name of the sweep directory (swp_name). 
%
% Processing parameters are read from the input json_file.
% This is an ascii JSON formatted parameter file that contains all the
% information needed to process a covis sweep.
%
% The sweep directory contains a set of files for each ping. 
% The files in the sweep directory must conform to the file name
% convensions and data formats defined in the document Covis_data.pdf and
% the R7038 data format defined in the document Reson_data_format.html.
% Meta data for the sweep is contained in a sweep.json file.
% The meta data each ping is contianed a the file of the form
% ('rec_7000_%06d.json',ping_number) and the associated binary data file
% name has the form ('rec_7038_%06d.bin',ping_number). 
% The binary data files (*.bin) contain element level (quadrature) samples.
% The attitude data for each ping is contained in the 'index.csv' file.
% JSON files are parsed using the function 'parse_json'.  
%
% This function returns a structure (covis) that contains all the data and
% meta data for the processed sweep. Processed data is gridded onto an 
% evenly spaced rectangular grid stored in the covis.grid structure.  
% Gridding is done using the 'l3grid_doppler' function and nearest neighbor 
% linear interpolation method.
% The data grid is defined in the fixed world coordinate system with the
% sonar in the center of the rectangular coordinate system. 
% The y-direction is North, x-direction is East, and z-direction is Up.
% Coordinate transformations from the sensor coordinate system of
% (range, beam azimuth) are done using the function covis_coords().
%
%
% ----------
%  Version 1.0 - 10/2010,  
%    cjones@apl.washington.edu, drj@apl.washington.edu, bemis@rci.rutgers.edu
%  Version 1.1 - 05/2011,
%     xupeng_66@hotmail.com
global Verbose;

swp_dir = fullfile(swp_path, swp_name);

% check that archive dir exists
if(~exist(swp_dir))
    error('Sweep directory does not exist\n');
    return;
end

% check that json input file exists
%if(~exist(json_file))
    %error('JSON input file does not exist\n');
    %return;
%end

% parse sweep.json file in data archive
swp_file = 'sweep.json';
if(~exist(fullfile(swp_dir, swp_file)))
    error('sweep.json file does not exist\n');
    return;
end
json_str = fileread(fullfile(swp_dir, swp_file));
swp = parse_json(json_str);

% set sweep path and name
swp.path = swp_path;
swp.name = swp_name; 

% parsing the json input file for the user supplied parameters
if(isempty(json_file) | (json_file == 0)) 
   % default json input file
   json_file = fullfile('input', 'covis_doppler.json');
end
json_str = fileread(json_file);
covis = parse_json(json_str);
if(strcmp(lower(covis.type), 'doppler') == 0)
    fprintf('Incorrect covis input file type\n');
    return;
end

Verbose = covis.user.verbose;
Debug_Plot = covis.user.debug;

% define a 2D rectangular data grid
for n=1:length(covis.grid)
   [covis.grid{n}] = covis_rectgrid_doppler(covis.grid{n}); % corr grid
   covis.grid{n}.name = swp.name;
end

% set local copies of covis structs
usr = covis.user;
pos = covis.sonar.position;
dsp = covis.processing;
bfm = covis.processing.beamformer;
cal = covis.processing.calibrate;
filt = covis.processing.filter;
cor = covis.processing.correlation;

% Set the type of beamforming (fast, fft, ...)
if(~isfield(bfm,'type'))
    bfm.type = 'fast';
    if(Verbose) fprintf('Setting beamform type: %s\n',bfm.type); end;
end
bfm_type = bfm.type;

% Set compass declination
if(~isfield(pos,'declination'))
    pos.declination = 18.0;
end

% calibration parameters
if(~isfield(cal,'mode'))
    cal.mode = 'VSS'; % 'VSS' or 'TS'
end

% set position of sonar
% should use covis.position info, but for now ...
if(~isfield(pos,'altitude'))
    pos.altitude = 4.2;
end
alt = pos.altitude;
origin = [0,0,alt]; % sonar is always at (0,0,0) in world coords

% directory list of *.bin file
file = dir(fullfile(swp_dir, '*.bin'));
nfiles = length(file);

% Read index file
% The index file contains the sweep parameters:
% ping,seconds,microseconds,pitch,roll,yaw,kPAngle,kRAngle,kHeading
% in csv format
ind_file = 'index.csv';
% should check if file exists
csv = csvread(fullfile(swp_dir, ind_file), 1, 0);
if(size(csv,1) ~= nfiles)
    fprintf('index size and file number mismatch');
end

if(Verbose)
    fprintf('Parsing %s\n', fullfile(swp_dir, ind_file));
end

% save index data in ping structure
for n=1:nfiles
    png(n).num = csv(n,1);
    png(n).sec = (csv(n,2) + csv(n,3)/1e6);
    % save rotator angles
    png(n).rot.pitch = csv(n,4);
    png(n).rot.roll = csv(n,5);
    png(n).rot.yaw = csv(n,6)';
    % save tcm6 angles
    png(n).tcm.kPAngle = csv(n,7)';
    png(n).tcm.kRAngle = csv(n,8)';
    png(n).tcm.kHeading = (pos.declination + csv(n,9))';
end

% find the number of bursts in the sweep and number of pings in each burst
% by checking when the elevation changes
[ burst ] = covis_parse_bursts( png );

% range of elev steps to process (in degrees)
elev_start = (covis.processing.bounds.pitch.start);
elev_stop = (covis.processing.bounds.pitch.stop);

covarsum = 0;
% loop over bursts
nbursts = length(burst);
for nb = 1:nbursts
    
    % check elevation
    if((burst(nb).elev < elev_start) || (burst(nb).elev > elev_stop))
        nb_start = nb+1;
        continue;
    end
    
    if(Verbose)
        fprintf('Burst %d: Elevation %f\n', nb, burst(nb).elev);
    end;
    
    % loop over pings in a burst
    bf_sig_cal = zeros(0);
    for np = 1:burst(nb).npings
        
        % parse filenames
        n = burst(nb).start_ping + (np-1);
        bin_file = file(n).name;
        [type,ping_num] = strread(bin_file,'rec_%d_%d.bin');

        json_file = sprintf('rec_7000_%06d.json',ping_num);
        
        % read ping meta data from json file
        json_str = fileread(fullfile(swp_dir, json_file));
        json = parse_json(json_str);
        png(n).hdr = json.hdr;
        
        % define sonar attitude (use TCM6 angles)
        elev = (pi/180) * png(n).tcm.kPAngle;
        roll = (pi/180) * png(n).tcm.kRAngle;
        yaw = (pi/180) * png(n).tcm.kHeading;
        
        if(Verbose > 1)
            fprintf(' %s: elev %f, roll %f, yaw %f\n', bin_file, ...
                elev*180/pi, roll*180/pi, yaw*180/pi);
        end;
        
        % read raw element quadrature data
        [hdr, data] = covis_read(fullfile(swp_dir, bin_file));

        if(np == 1)
            monitor = data;
        end
        
        if(strfind(dsp.ping_combination.mode,'diff'))
            % Correct phase using first ping as reference
            data = covis_phase_correct(png(n), monitor, data);
        end
        
        % Calculate the covariance function of the monitor
        % signal. The covariance function will be used to correct the 
        % offset in the radial velocity estimates caused by the timing 
        % mismatch between the clocks in COVIS for data generation and 
        % digitization.  
        [covar] = covis_offset_covar(data,png(n));
        covarsum = covarsum+covar;
        
        
        
        % Apply Filter to data
        [data, filt, png(n)] = covis_filter_doppler(data, filt, png(n));
   
        
      
        % define beamformer parameters
        bfm.fc = png(n).hdr.xmit_freq;
        bfm.c = png(n).hdr.sound_speed;
        bfm.fs = png(n).hdr.sample_rate;
        bfm.first_samp = hdr.first_samp + 1;
        bfm.last_samp = hdr.last_samp;
        
        % beamform
        [bfm, bf_sig] = covis_beamform(bfm, data);
        
        if((nb == nb_start) && (np == 1))
            if(Verbose > 1)
                png(n).hdr  % View essential parameters
            end
        end
        
        % save ping in the burst array
        bf_sig_cal(:,:,np) = covis_calibration(bf_sig, bfm, png(n), cal);
    
    end % End of loop over pings in burst
    
    % Compute Doppler shift using entire burst
    range = bfm.range;
    
    [vr,vr_filt,rc,I,I_filt,vr_std,I_std,covar] = covis_incoher_dop_xgy(png(n).hdr, dsp, range, bf_sig_cal);
    
    % define sonar attitude
    %elev = (pi/180) * png(n).tcm.kPAngle;
    elev = (pi/180) * burst(nb).elev;
    roll = (pi/180) * png(n).tcm.kRAngle;
    yaw = (pi/180) * png(n).tcm.kHeading;
    
    % transform sonar coords into world coords
    azim = bfm.angle;
    [xv, yv, zv] = covis_coords(origin, rc, azim, yaw, roll, elev);
    
    % sin of elevation angle
    sin_elev = zv./sqrt(xv.^2+yv.^2+zv.^2);
    %cos_elev=sqrt(1-sin_elev.^2);
    % Vertical velocity under assumption that flow is vertical
    vz_filt = vr_filt./sin_elev;
    vz=vr./sin_elev;
    % grid the data
    for n=1:length(covis.grid)
      grd = covis.grid{n};
        switch lower(grd.type)
        % grid the vertical velocity data
        case {'velocity','doppler velocity'}
          [grd.v,grd.v_filt,grd.vr,grd.w,grd.std,grd.covar] = l3grid_doppler(xv,yv,zv,vz,vr_filt,vr,vr_std,covar,grd.x,grd.y,grd.z,grd.v,grd.v_filt,grd.vr,grd.w,grd.std,grd.covar);
        % grid the intensity data
        case {'intensity','doppler intensity'}
          [grd.v,grd.v_filt,grd.vr,grd.w,grd.std,grd.covar] = l3grid_doppler(xv,yv,zv,I,I_filt,vr,I_std,covar,grd.x,grd.y,grd.z,grd.v,grd.v_filt,grd.vr,grd.w,grd.std,grd.covar);
        otherwise disp('Unknown grid type.')
        end
        covis.grid{n} = grd;
    end
    if(Debug_Plot)
        figure(1); clf;
        %pcolor(xv,yv,v); shading flat; axis equal; caxis([0 1]);
        surf(xv,yv,zv,vz_filt); shading flat; axis equal; %caxis([0 1]);
        caxis([0 50])
        %axis([-50 50 -50 50 -10 40]);
        if(isfield(usr,'view'))
            view(usr.view.azimuth, usr.view.elevation);
        else
            view([1,1,1]);
        end
        title(['Vertical Velocity (cm/s), Burst No. ' int2str(nb)])
        %str = sprintf('Ping Number %d: Elevation %.2f, Roll %.2f, Yaw %.2f\n', ...
        %    png(n).hdr.ping_num, elev*180/pi, roll*180/pi, yaw*180/pi);
        %title(str);
        colorbar
        refresh;
        pause(1);
    end;
end   % End of burst loop


% normalize the velocity grid with the grid weights
% save the grid structures in the main covis struct
for n=1:length(covis.grid)
  grd = covis.grid{n};
  m = find(grd.w);
  grd.v(m) = grd.v(m)./grd.w(m);
  grd.v_filt(m)=grd.v_filt(m)./grd.w(m);
  grd.std(m) = grd.std(m)./grd.w(m);
  grd.vr(m)=grd.vr(m)./grd.w(m);
  covis.grid{n} = grd;
end
% assign the total covariance function to a new field in the COVIS
% structure array
covis.grid{1}.offset_covar = covarsum;


% save the local copies of covis structs
covis.sweep = swp;
covis.ping = png;
covis.calibrate = pos;
covis.processing.beamformer = bfm;
covis.processing.calibrate = cal;
covis.processing.filter = filt;
covis.burst = burst;

% save covis for later use
if(~isfield(usr,'outpath'))
    usr.outpath = 'output';  % default
    if(Verbose) fprintf('Setting user output path: %s\n',usr.outpath); end;
end


output_path = fullfile(swp_path,usr.outpath);
if(~exist(output_path,'dir'))
    mkdir(output_path);
end
filename = fullfile(output_path, [covis.sweep.name '.mat']);
if(exist(filename,'file'))
    fprintf('Warning: overwiting %s\n', filename);
end
save(filename,'covis');

close
end

% This function is used to calculate the covariance function of the monitor
% signal. The covariance function will be used to correct the offset in the 
% radial velocity estimates caused by the timing mismatch between the 
% clocks in COVIS for data generation and digitization. 
function [covar] = covis_offset_covar(data,ping)
% input:
% data: baseband complex signal
% ping: structure array of the constant parameters for each ping
% output:
% covar: covariance function
nchan = size(data,2);

sample_rate = ping.hdr.sample_rate;
pulse_width = ping.hdr.pulse_width;


% Number of samples to keep from monitor channel
 nkeep = round(3*sample_rate*pulse_width);

% The monitor channel is the last channel
 monitor = data(1:nkeep,nchan);

% calculate the covariance function
covar = sum(monitor(1:end-8).*conj(monitor(9:end)));




end




