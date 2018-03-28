import pytest
import pycovis.postprocess as postprocess

@pytest.fixture
def pp_instance():
    postprocess.initialize_runtime(['-nojvm','-nodisplay'])
    return postprocess.initialize()

def test_imaging_sweep():
    pp = pp_instance()

    testFile = "/input/imaging/APLUWCOVISMBSONAR001_20130322T030040.316Z-IMAGING.tar.gz"
    outputDir = "/output/imaging/"

    matfile = pp.covis_imaging_sweep(testFile, outputDir, '')

    pp.terminate()
