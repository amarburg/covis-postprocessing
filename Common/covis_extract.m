function [swp_path, swp_name] = covis_extract(filename, outputdir)
%
% Extract a COVIS archive file (zip or tar.gz).
% Inputs:
%   filename - full archive name
%   outputdir - directory to extracte the contents of filename
% Outputs:
%   swp_path - path to extracted directory
%   swp_name - name of extracted directory
% If filename is null or zero, the user is prompted to select
% an archive file.
% If it has already been extracted in the same location as filename,
% return with swp_path set to the location of the existing directory.
% If the archive is already extracted in outputdir, return with swp_path
% set to outputdir.
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
%  Version 1.0 - 10/2011,  cjones@apl.washington.edu
%

swp_path = 0;
swp_name = 0;

% pick a sweep archive, if none given
if(isempty(filename))
    error('No filename specified')
    return

%    [swp_name, swp_path] = uigetfile('*.*','Pick a COVIS Sweep Archive');
%    if(swp_name == 0)
%       return;
%    end;
%    filename = fullfile(swp_path, swp_name);
end

if(~exist(filename, 'file'))
    fprintf('COVIS archive %s does not exist\n', filename);
    return;
end

% get the file name parts
[swp_path, swp_name, ext] = fileparts(filename);

% check if archive has already been extracted in the same location
% as the filename
if(exist(fullfile(swp_path, swp_name), 'dir'))
    % return with swp_path set to same location as filename
    fprintf('COVIS archive is already extracted, using %s\n', [swp_path swp_name]);
    return;
end

% if no outputdir is given, extract it in the same location as filename
if(isempty(outputdir)) 
   outputdir = swp_path;
end

% unzip the sweep archive
if(strcmp(ext,'.zip'))

    % unzip file, if it doesn't exist
    if(~exist(fullfile(outputdir, swp_name)))
        fprintf('Extracting archive into %s\n', outputdir);
        fprintf('Unzipping COVIS archive %s ... ', swp_name);
        files = unzip(filename, outputdir);
        fprintf(' done\n');
        % check if zip file has been renamed
        swp_dir = fileparts(files{1});
        if ~strcmp(swp_dir, fullfile(outputdir, swp_name))
            movefile(swp_dir, fullfile(outputdir, swp_name));
        end
    end
    % set new sweep path
    swp_path = outputdir;

elseif(strcmp(ext,'.gz'))

    % untar the sweep archive, if it doen't exist
    [swp_path, swp_name, ext] = fileparts(fullfile(swp_path,swp_name));
    if(~strcmp(ext,'.tar'))
        fprintf('Unknown Covis archive type\n');
        covis = [];
        return;
    end;
    % untar file, if doesn't exist
    if(~exist(fullfile(outputdir,swp_name)))
        fprintf('Extracting archive into %s\n', outputdir);
        fprintf('Untarring COVIS archive %s ... ', swp_name);
        tarfile = char(gunzip(filename, outputdir));
        files = untar(tarfile, outputdir);
        delete(tarfile);
        fprintf(' done\n');
        % check if tar file has been renamed
        swp_dir = fileparts(files{1});
        if ~strcmp(swp_dir, fullfile(outputdir, swp_name))
            movefile(swp_dir, fullfile(outputdir, swp_name));
        end
    end
    % set new sweep path
    swp_path = outputdir;

elseif(strcmp(ext,'.tar'))

    % untar file, if doesn't exist
    if(~exist(fullfile(outputdir,swp_name)))
        fprintf('Untarring COVIS archive %s ... ', filename);
        files = untar(filename, outputdir);
        fprintf(' done\n');
        % check if tar file has been renamed
        swp_dir = fileparts(files{1});
        if ~strcmp(swp_dir, fullfile(outputdir, swp_name))
            movefile(swp_dir, fullfile(outputdir, swp_name));
        end
    end
    % set new sweep path
    swp_path = outputdir;

else
    warning(['Unknown COVIS archive type: ''' ext '''. This will probably cause an error.']);
    swp_name = [];
    swp_path = [];

end


end
