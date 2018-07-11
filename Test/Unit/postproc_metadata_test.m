

result = postproc_metadata();

assert(isfield(result,'verstr'))
assert(strlength(result.verstr) > 0)

assert(isfield(result,'gitrev'))

%% The Makefile should set the git tag "test"
assert(isfield(result,'gittags'))
assert(contains(result.gittags,'test'))
