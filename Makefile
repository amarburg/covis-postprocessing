
# Runs the run_all_tests() function in the Tests/ directory.
# Requires Matlab!!
#
test:
	cd Test/ && matlab -nodisplay -nosplash -r "run_all_tests()"


.PHONY: test
