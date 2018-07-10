function temp = test_tempdir()

  temp = getenv('COVIS_TEST_TEMP');

  if isempty(temp)
    temp = tempname();
    mkdir(temp);
  end
