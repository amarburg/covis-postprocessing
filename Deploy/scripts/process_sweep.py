import pytest
import pycovis.postprocess as postprocess

postprocess.initialize_runtime(['-nojvm','-nodisplay'])
pp=postprocess.initialize()

testFile = "/input/imaging/APLUWCOVISMBSONAR001_20130322T030040.316Z-IMAGING.tar.gz"
outputDir = "/output/imaging/"

matfile = pp.covis_imaging_sweep(testFile, outputDir, '')

#matfile = "/output/imaging/APLUWCOVISMBSONAR001_20130322T030040.316Z-IMAGING.mat"
imgfile = pp.covis_imaging_plot(matfile, outputDir, '');

pp.terminate()
