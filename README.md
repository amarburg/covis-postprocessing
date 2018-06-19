# COVIS Post-Processing

Matlab code for parsing and post-processing data from the COVIS instrument as
installed on the ONC Neptune Cabled Array at the Endeavour vent field from
2010-2015 and to be installed on the OOI Cabled Array at the Ashes vent field 2018-2022.

`Common/` ... contains Matlab code.

`Test/` contains a Matlab-language test suite.    On a (Linux or Mac?) machine with Matlab installed, this test suite can be run by `make test` at the top level of this repo.

The `Deploy/` directory contains code related to packaging this code as a Python library for distribution.
