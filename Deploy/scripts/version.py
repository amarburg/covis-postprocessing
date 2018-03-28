import pytest
import pycovis.postprocess as postprocess


postprocess.initialize_runtime(['-nojvm','-nodisplay'])
pp=postprocess.initialize()

print("Matlab version:               %s" % pp.version() )
print("COVIS postprocessing version: %s" % pp.covis_version() )

pp.terminate()
