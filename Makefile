help:
	@echo "make test         Runs Matlab-based test suite (from command line)"

test:
	cd Test/ && matlab -nodisplay -nojvm -nosplash -r "  addpath('../Common'); result = runtests(); disp(result); exit()"

.PHONY: test
