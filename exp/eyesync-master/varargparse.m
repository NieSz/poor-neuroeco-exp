% Ironically, matlab's builtin inputParser has a fairly awkward input syntax,
% which tends to result in lots of boilerplate code. This wrapper function
% handles the standard use case (all arguments are named and optional, and
% disables some overly flexible default inputParser behaviours: CaseSensitive=1,
% PartialMatching=0, StructExpand=0).
%
% Requires a fairly recent matlab version (R2015?)
%
% INPUTS (all optional):
% args (cell) - cell array of input args (e.g., varargin in caller)
% defaults (struct) - struct of default variable names and values
% keepunmatched (false) - store input arguments that do not appear in defaults
%   in a second output struct (default behaviour is to raise an exception when
%   unknown inputs are encountered)
% tests (struct) - struct with tests for some of the of the input args
% ignoreempty (true) - use default for any input that evaluates to isempty
%
% OUTPUTS:
% outarg - struct with one field per variable that appears in defaults
% unmatch - struct with one field per variable that was entered but did not
%   appear in defaults (only if keepunmatched=1)
%
% See also: varargs2structfields, structfields2varargs
%
% [outargs,unmatch] = varargparse(args,defaults,keepunmatched,tests)
function [outargs,unmatch] = varargparse(args,defaults,keepunmatched,tests,ignoreempty)

% input parse (meta meta)
unmatch = struct;
if ~exist('defaults','var') || isempty(defaults)
    defaults = struct;
end
assert(numel(defaults)==1,'defaults must be scalar struct-like');
if ~exist('args','var') || isempty(args)
    % no need for all this instancing
    outargs = defaults;
    return;
end
assert(iscell(args),'args must be cell array');
assert(mod(numel(args),2)==0,...
    'expected even number of args (key/value pairs)');
if ~exist('keepunmatched','var') || isempty(keepunmatched)
    keepunmatched = false;
end
if ~exist('tests','var') || isempty(tests)
    tests = struct;
end
assert(numel(tests)==1,'tests must be scalar struct-like');
if ~exist('ignoreempty','var') || isempty(ignoreempty)
    ignoreempty = true;
end

if ignoreempty
    emptytest = cellfun(@isempty,args(2:2:end));
    % need to remove every case, but in the full array
    emptytest = [emptytest;emptytest];
    emptytest = emptytest(:);
    args(emptytest) = [];
end

% instance config
p = inputParser;
p.CaseSensitive = true;
p.StructExpand = false;
if isfield(p,'PartialMatching')
    % not present in R2013a
    p.PartialMatching = false;
end
p.KeepUnmatched = keepunmatched;
parfun = 'addParameter';
if ~ismethod(p,parfun)
    % matlab uses inconsistent method names over versions
    parfun = 'addParamValue';
end

for fn = fieldnames(defaults)'
    fnstr = fn{1};
    pararg = {p,fnstr,defaults.(fnstr)};
    if isfield(tests,fnstr)
        pararg{end+1} = tests.(fnstr);
    end
    feval(parfun,pararg{:});
end

parse(p,args{:});
unmatch = p.Unmatched;
outargs = p.Results;
