function [filename] = testfiles(mode,filetype)

  root = "../../covis-test-data/";

  if filetype == "basename"
    switch mode
      case "imaging"
        filename = "APLUWCOVISMBSONAR001_20130322T030040.316Z-IMAGING";
      case "diffuse"
        filename = "APLUWCOVISMBSONAR001_20130322T034811.901Z-DIFFUSE";
      case "doppler"
        filename = "APLUWCOVISMBSONAR001_20130322T030922.697Z-DOPPLER";
    end
    return
  end

  filename = fullfile( root, mode, testfiles(mode, "basename") )

  switch filetype
    case "gz"
      filename = strcat(filename,".tar.gz");
  end
