function [metadata] = postproc_metadata()

  metadata = struct;
  metadata.verstr = covis_version();

  % Git metadata is only relevant when running this code live.  Once
  % compiled into Python library,

  % Default values
  metadata.gitrev=''
  metadata.gittag=''

  [status,cmdout] = system('git rev-parse HEAD')
  if status > 0
    metadata.gitrev = cmdout

    [status,cmdout] = system('git describe --tags')
    if status > 0
      metadata.gittags = cmdout
    end

  else
    % If not a git repo, try to use static values
    gitinfo = static_git_info()

    metadata.gitrev = gitinfo.gitrev
    metadata.gittags = gitinfo.gittags
  end

end
