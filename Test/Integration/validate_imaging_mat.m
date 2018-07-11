function validate_imaging_mat(filename)

  clear('covis')
  loaded = load(filename);

  assert(isfield(loaded,'covis'), "Returned .mat file does not contain covis variable")

  covis = loaded.covis;

  validate_metadata_mat(covis)
