

temp = tempname()
mkdir(temp)

[out_path,out_name] = covis_extract(testfiles('diffuse', 'gz'), temp)
diffuseMatFile = covis_diffuse_sweep(out_path, out_name, '../Common/input/covis_diffuse.json')

%imgfile = covis_diffuse_plot(imagingProducedMatFile, cd, '');
