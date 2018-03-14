function [hdr, data] = covis_read( file )
% Read Reson R7038 data file.  
% This function returns a structure containing the file header information 
% and data matrix. The data matrix is of size [number_samples,number_chans].
% The data matrix is complex with each data column representing the 
% discrete time series of the baseband recieved signal from each element.
% Each data sample is a quadrature pair (I&Q) with 12 bits of resolution.
% The header structure (hdr) contains all the data read from the file header. 
% ---
% Version 1.0 - cjones@apl.washington.edu 06/2010
%
global Verbose

format = 'ieee-le';
fp = fopen(file,'r',format);
if(fp <= 0) 
    error('Error openning f7038 data file');
end

hdr.serial_number = fread(fp, 1, 'uint64');
hdr.number = fread(fp, 1, 'uint32');
reserved = fread(fp, 1, 'uint16'); 
hdr.total_nelems = fread(fp, 1, 'uint16');
hdr.nsamps = fread(fp, 1, 'uint32');
hdr.nelems = fread(fp, 1, 'uint16');
hdr.first_samp = fread(fp, 1, 'uint32');
hdr.last_samp = fread(fp, 1, 'uint32');
hdr.samp_type = fread(fp, 1, 'uint16');
reserved = fread(fp, 7, 'uint32');

nsamps = hdr.nsamps;
nelems = hdr.nelems;

% read element number list
hdr.element = fread(fp, nelems, 'uint16');

% read data (I&Q pairs) for all elements 
data = fread(fp, [2*nelems, nsamps], 'int16');

fclose(fp);

if(size(data,2) < nsamps) 
    fprintf('Error reading %d samples\n', nsamps);
end

% make a complex number from real and imag components
data = data(1:2:end-1,:)' + 1i*(data(2:2:end,:)');
end

