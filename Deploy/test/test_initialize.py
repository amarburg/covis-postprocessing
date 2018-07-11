import pytest
from pycovis.postprocess import runtime


def test_version():
    with runtime.Runtime() as pp:
        matlab_version = pp.version()
        covis_version  = pp.covis_version()
