from pycovis.postprocess import sweep

from pathlib import Path

testFile = "/input/imaging/APLUWCOVISMBSONAR001_20111001T030039.826Z-IMAGING.tar.gz"
outputDir = "/output/imaging/"


sweep.process_sweep(testFile, outputDir)
