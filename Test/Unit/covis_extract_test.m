
%% Only test the diffuse code ... the others will be tested as part of
%% other test functions

for mode = ["diffuse"]

  temp = tempname()
  mkdir(temp)

  [out_path,out_name] = covis_extract(testfiles(mode, "gz"), temp)

  assert( strcmp(out_path, temp ) )
  assert( strcmp(out_name, testfiles(mode, "basename")) )

  %% Todo:  Check contents of the archive

end
