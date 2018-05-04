
test:
	cd Test/ && matlab -nodisplay -nojvm -nosplash -r "run_all_tests()"


.PHONY: test
