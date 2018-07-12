import pytest
from pycovis.postprocess import runtime


# def test_diffuse_process_sweep():
#     testFile = "/input/APLUWCOVISMBSONAR001_20111001T215909.172Z-DIFFUSE.tar.gz"
#     outputDir = "/output/imaging/"
#
#     with runtime.Runtime() as pp:
#         matfile = pp.covis_diffuse_sweep(testFile, outputDir)
#         plotfile = pp.covis_diffuse_plot(matfile,outputDir)

def test_diffuse_sweep():
    testFile = "/input/APLUWCOVISMBSONAR001_20111001T215909.172Z-DIFFUSE.tar.gz"
    outputDir = "/output/diffuse/"

    with runtime.Runtime() as pp:
        matfile = pp.covis_diffuse_sweep(testFile, outputDir)
        plotfile = pp.covis_diffuse_plot(matfile,outputDir)

    #matfile = pp.covis_diffuse_sweep(testFile, outputDir, '')
