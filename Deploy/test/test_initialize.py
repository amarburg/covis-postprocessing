import pytest
import pycovis.postprocess as postprocess


@pytest.fixture
def pp_instance():
    postprocess.initialize_runtime(['-nojvm','-nodisplay'])
    return postprocess.initialize()

def test_initialize():
    pp = pp_instance()
    pp.terminate()

def test_version():
    pp = pp_instance()

    matlab_version = pp.version()
    covis_version  = pp.covis_version()

    pp.terminate()
