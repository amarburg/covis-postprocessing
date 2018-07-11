# COVIS Post-Processing

Matlab code for parsing and post-processing data from the COVIS instrument as
installed on the ONC Neptune Cabled Array at the Endeavour vent field from
2010-2015 and to be installed on the OOI Cabled Array at the Ashes vent field 2018-2022.

`Common/` ... contains Matlab code.

`Test/` contains a Matlab-language test suite.    On a (Linux or Mac?) machine
with Matlab and Gnu make installed:

  * `make test` or `make unittest` will run a (relatively fast) unit test suite.
  * `make integrationtest` will run a more thorough integration test suite.  This will
        fully process multiple COVIS files and may take some time to run.


The `Deploy/` directory contains code related to packaging this code as a Python library for distribution.

The `Test/` directory contains unit tests.  To run these tests on the command line, run `make test` from the top level from a (Linux?) machine with Matlab installed.
