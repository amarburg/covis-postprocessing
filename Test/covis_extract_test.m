
for mode = ["diffuse"]

  temp = tempname()
  mkdir(temp)

  [out_path,out_name] = covis_extract(testfiles(mode, "gz"), temp)

  assert( strcmp(out_path, temp ) )
  assert( strcmp(out_name, testfiles(mode, "basename")) )

end
