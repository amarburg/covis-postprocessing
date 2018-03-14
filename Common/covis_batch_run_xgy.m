% This pogram is used to process a batch of COVIS datasets within a
% selected time period at a time

% set up the directory of the data files (e.g., the following chunk of code 
% tells the program to process the diffuse flow data recorded from May 1st 
% to 11th, 2015. Note that one needs to assign the correct directory under 
% which the data are stored to 'data_path'). 
data_path = 'F:\COVIS\covis_data\diffuse_flow\2015\'; 
month = 'may';  
dates = [1:11];
request = 'process';

% combine Doppler output files from each day
seq_files = struct([]);
p_f = cell(0);
n_f = cell(0);
e_f = cell(0);

for i_date = 1:length(dates)
    p_sub = cell(0);
    n_sub = cell(0);
    e_sub = cell(0);
    if dates(i_date)<10
        path_to_data=[data_path,month,'\decimated\0',sprintf('%d',dates(i_date))];
    else
        path_to_data=[data_path,month,'\decimated\',sprintf('%d',dates(i_date))];
    end
    seq_files_sub = dir(fullfile(path_to_data,'APL*.*'));
    %seq_files_sub = dir(fullfile(path_to_data,'*.zip'
    for i_sub = 1:length(seq_files_sub)
        [p_sub{i_sub},n_sub{i_sub},e_sub{i_sub}] = fileparts(fullfile(path_to_data,seq_files_sub(i_sub).name));
    end
    p_f = [p_f,p_sub];
    n_f = [n_f,n_sub];
    e_f = [e_f,e_sub];
end


if length(n_f)>=1
    display('Files that will be processed:')
    for k=1:length(n_f)
        display([n_f{k},e_f{k}])
    end
    if strcmp(request,'process')
        %for k = 1
        for k=1:length(n_f)
            display(['now running: covis_process_sweep(' ,p_f{k}, ',',n_f{k},e_f{k},'[])'])
            try
                covis_process_sweep(p_f{k},[n_f{k},e_f{k}])
            catch me
                disp('an error happens when processing the file');
                continue
            end
        end
    end
else
    display('No files found')
end