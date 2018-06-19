test:
	cd Test/ && matlab -nodisplay -nojvm -nosplash -r "  addpath('../Common'); result = runtests(); disp(result); exit()"

.PHONY: test
