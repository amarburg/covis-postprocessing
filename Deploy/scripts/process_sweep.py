from pycovis.postprocess import runtime

from pathlib import Path



testFile = "/input/APLUWCOVISMBSONAR001_20111001T210757.973Z-IMAGING.tar.gz"
outputDir = "/output/imaging/"

with runtime.Runtime() as pp:
    matfile = pp.covis_imaging_sweep(testFile, outputDir)
    pprint.pprint(matfile)
    assert( os.path.isfile(matfile) )

    plotfile = pp.covis_imaging_plot(matfile,outputDir)
