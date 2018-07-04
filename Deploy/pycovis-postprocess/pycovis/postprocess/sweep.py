from pathlib import Path

from . import runtime

def process_sweep(input, outdir):
    with runtime.Runtime() as pp:
        inpath = Path(input)
        matfile = pp.covis_imaging_sweep(input, outdir, '')

        imgfile = pp.covis_imaging_plot(matfile, outdir, '')

    return [matfile, imgfile]

# if __name__ == "__main__":
#     testFile = "/input/imaging/APLUWCOVISMBSONAR001_20111001T030039.826Z-IMAGING.tar.gz"
#     outputDir = "/output/imaging/"
#
#     process_sweep(testFile, outputDir)
