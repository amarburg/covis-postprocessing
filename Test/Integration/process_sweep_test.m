
%% Test with previously unpacked data
[out_path,out_name] = covis_extract(testfiles('imaging', 'gz'), test_tempdir());

metadata = postproc_metadata();
imagingMatFile = covis_process_sweep( fullfile(out_path, out_name), ...
                                    'outputdir', tempdir(), ...
                                    'json_file', "../../Common/input/covis_image.json", ...
                                    'metadata', metadata);
assert(~isempty(imagingMatFile), "covis_imaging_sweep returned an empty .mat file path")

clear('covis')
loaded = load(imagingMatFile);

assert(isfield(loaded,'covis'), "Returned .mat file does not contain covis variable")

covis = loaded.covis;
assert(isfield(covis,'metadata'), "covis.metadata does not exist")
assert(~isempty(covis.metadata.gittags), "covis.metadata.gittags is empty")
assert(~isempty(covis.metadata.gitrev), "covis.metadata.gitrev is empty")
assert(isfield(covis, 'sweep'), "covis.sweep does not exist")


%imgfile = covis_diffuse_plot(imagingProducedMatFile, cd, '');
