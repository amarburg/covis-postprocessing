function validate_imaging_mat(filename)

  clear('covis')
  loaded = load(filename);

  assert(isfield(loaded,'covis'), "Returned .mat file does not contain covis variable")

  covis = loaded.covis;
  assert(isfield(covis,'metadata'), "covis.metadata does not exist")
  assert(~isempty(covis.metadata.gittags), "covis.metadata.gittags is empty")
  assert(~isempty(covis.metadata.gitrev), "covis.metadata.gitrev is empty")
  assert(isfield(covis, 'sweep'), "covis.sweep does not exist")
