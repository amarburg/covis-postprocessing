

%% Test with gz data
metadata = postproc_metadata();
imagingMatFile = covis_process_sweep( testfiles('imaging', 'gz'), tempdir(), ...
                                    'json_file', "../../Common/input/covis_image.json", ...
                                    'metadata', metadata);

assert(~isempty(imagingMatFile), "covis_imaging_sweep returned an empty .mat file path")
validate_imaging_mat( imagingMatFile )




%% Test with previously unpacked data
[out_path,out_name] = covis_extract(testfiles('imaging', 'gz'), test_tempdir());

metadata = postproc_metadata();
imagingMatFile = covis_process_sweep( fullfile(out_path, out_name), tempdir(), ...
                                    'json_file', "../../Common/input/covis_image.json", ...
                                    'metadata', metadata);

assert(~isempty(imagingMatFile), "covis_imaging_sweep returned an empty .mat file path")
validate_imaging_mat( imagingMatFile )


%imgfile = covis_diffuse_plot(imagingProducedMatFile, cd, '');
