from pycovis.postprocess import sweep

from pathlib import Path



testFile = "/input/imaging/APLUWCOVISMBSONAR001_20111001T030039.826Z-IMAGING.tar.gz"
outputDir = "/output/imaging/"

with runtime.Runtime() as pp:
    inpath = Path(input)
    matfile = pp.covis_imaging_sweep(input, outdir, '')

    imgfile = pp.covis_imaging_plot(matfile, outdir, '')
