import pytest
import pycovis.postprocess as postprocess


def version():
    postprocess.initialize_runtime(['-nojvm','-nodisplay'])
    pp=postprocess.initialize()

    print("Matlab version:               %s" % pp.version() )
    print("COVIS postprocessing version: %s" % pp.covis_version() )

    pp.terminate()


if __name__ == "__main__":
    version()
