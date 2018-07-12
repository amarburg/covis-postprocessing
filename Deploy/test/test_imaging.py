import os.path

import pytest
from pycovis.postprocess import runtime

import pprint

# def test_imaging_process_sweep():
#     testFile = "/input/APLUWCOVISMBSONAR001_20111001T210757.973Z-IMAGING.tar.gz"
#     outputDir = "/output/imaging/"
#
#     with runtime.Runtime() as pp:
#         matfile = pp.covis_process_sweep(testFile, outputDir)
#         assert( os.path.isfile(matfile) )
#
#         plotfile = pp.covis_imaging_plot(matfile,outputDir)

def test_imaging_sweep():
    testFile = "/input/APLUWCOVISMBSONAR001_20111001T210757.973Z-IMAGING.tar.gz"
    outputDir = "/output/imaging/"

    with runtime.Runtime() as pp:
        matfile = pp.covis_imaging_sweep(testFile, outputDir)

        plotfile = pp.covis_imaging_plot(matfile,outputDir)
