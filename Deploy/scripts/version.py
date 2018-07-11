from pycovis.postprocess import runtime


with runtime.Runtime() as pp:

    print("Matlab version:               %s" % pp.version() )
    print("COVIS postprocessing version: %s" % pp.covis_version() )
