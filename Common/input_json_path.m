function fullpath = input_json_path(filename)
  here = mfilename('fullpath')
  [filepath,fname,ext] = fileparts(here)
  fullpath = fullfile(filepath,'input',filename)
