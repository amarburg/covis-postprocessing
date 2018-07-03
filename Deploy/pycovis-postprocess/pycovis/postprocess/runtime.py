
import pycovis.matlab as pymatlab

class Runtime():

    def __init__(self):
        pymatlab.initialize_runtime(['-nodisplay'])
        self.pp = pymatlab.initialize()

    def __enter__(self):
        return self.pp

    def __exit__(self, *args):
        self.pp.terminate()
