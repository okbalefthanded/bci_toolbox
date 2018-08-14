function TestfRMField(doSpeed)
% Automatic test: fRMField
% This is a routine for automatic testing. It is not needed for processing and
% can be deleted or moved to a folder, where it does not bother.
%
% TestfRMField(doSpeed)
% INPUT:
%   doSpeed: Optional logical flag to trigger time consuming speed tests.
%            Default: TRUE. If no speed test is defined, this is ignored.
% OUTPUT:
%   On failure the test stops with an error.
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP, 32 bit
% Author: Jan Simon, Heidelberg, (C) 2010 matlab.THISYEAR(a)nMINUSsimon.de

% $JRev: R0j V:020 Sum:AB1BaJFwql1C Date:19-Aug-2010 23:57:17 $
% $License: NOT_RELEASED $
% $File: Tools\UnitTests_\TestfRMField.m $

% Initialize: ==================================================================
% Global Interface: ------------------------------------------------------------
FuncName = mfilename;

% Initial values: --------------------------------------------------------------
% Program Interface: -----------------------------------------------------------
if nargin == 0
   doSpeed = true;
end

% User Interface: --------------------------------------------------------------
% Do the work: =================================================================
disp(['== Test fRMField  ', datestr(now, 0)]);
disp(['  Version: ', which('fRMField')]);
pause(0.01);

fprintf('\n== Known answer tests:\n');

% Empty array:
S = [];
R = fRMField(S, '');
if isempty(R)
   disp('  ok: remove '''' from []');
else
   error([FuncName, ': Remove '''' from []']);
end

R = fRMField(S, 'field');
if isempty(R)
   disp('  ok: remove ''field'' from []');
else
   error([FuncName, ': Remove ''field'' from []']);
end

R = fRMField(S, {});
if isempty(R)
   disp('  ok: remove {} from []');
else
   error([FuncName, ': Remove {} from []']);
end

R = fRMField(S, {''});
if isempty(R)
   disp('  ok: remove {''''} from []');
else
   error([FuncName, ': Remove {''''} from []']);
end

R = fRMField(S, {'field'});
if isempty(R)
   disp('  ok: remove {''field''} from []');
else
   error([FuncName, ': Remove {''field''} from []']);
end

R = fRMField(S, {'field1', 'field2'});
if isempty(R)
   disp('  ok: remove {''field1'', ''field2''} from []');
else
   error([FuncName, ': Remove {''field1'', ''field2''} from []']);
end

% Empty struct:
S = struct([]);
R = fRMField(S, '');
if isempty(fieldnames(R))
   disp('  ok: remove '''' from struct([])');
else
   error([FuncName, ': Remove '''' from struct([])']);
end

R = fRMField(S, 'field');
if isempty(fieldnames(R))
   disp('  ok: remove ''field'' from struct([])');
else
   error([FuncName, ': Remove ''field'' from struct([])']);
end

R = fRMField(S, {});
if isempty(R)
   disp('  ok: remove {} from struct([])');
else
   error([FuncName, ': Remove {} from struct([])']);
end

R = fRMField(S, {''});
if isempty(R)
   disp('  ok: remove {''''} from struct([])');
else
   error([FuncName, ': Remove {''''} from struct([])']);
end

R = fRMField(S, {'field'});
if isempty(R)
   disp('  ok: remove {''field''} from struct([])');
else
   error([FuncName, ': Remove {''field''} from struct([])']);
end

R = fRMField(S, {'field1', 'field2'});
if isempty(R)
   disp('  ok: remove {''field1'', ''field2''} from struct([])');
else
   error([FuncName, ...
         ': Remove {''field1'', ''field2''} from struct([])']);
end

% Struct with 1 field:
S = struct('A', 1);
R = fRMField(S, '');
if isequal(S, R)
   disp('  ok: remove '''' from S.A');
else
   error([FuncName, ': Remove '''' from S.A']);
end

R = fRMField(S, 'field');
if isequal(S, R)
   disp('  ok: remove ''field'' from S.A');
else
   error([FuncName, ': Remove ''field'' from S.A']);
end

R = fRMField(S, {});
if isequal(S, R)
   disp('  ok: remove {} from S.A');
else
   error([FuncName, ': Remove {} from S.A']);
end

R = fRMField(S, {''});
if isequal(S, R)
   disp('  ok: remove {''''} from S.A');
else
   error([FuncName, ': Remove {''''} from S.A']);
end

R = fRMField(S, {'field'});
if isequal(S, R)
   disp('  ok: remove {''field''} from S.A');
else
   error([FuncName, ': Remove {''field''} from S.A']);
end

R = fRMField(S, {'field1', 'field2'});
if isequal(S, R)
   disp('  ok: remove {''field1'', ''field2''} from S.A');
else
   error([FuncName, ': Remove {''field1'', ''field2''} from S.A']);
end

% Remove existing fields:
R = fRMField(S, 'A');
if isempty(Xfieldnames(R))
   disp('  ok: remove ''A'' from S.A');
else
   error([FuncName, ': Remove ''A'' from S.A']);
end

R = fRMField(S, {'A'});
if isempty(Xfieldnames(R))
   disp('  ok: remove {''A''} from S.A');
else
   error([FuncName, ': Remove {''A''} from S.A']);
end

R = fRMField(S, {'A', 'field'});
if isempty(Xfieldnames(R))
   disp('  ok: remove {''A'', ''field''} from S.A');
else
   error([FuncName, ': Remove {''A'', ''field''} from S.A']);
end

% S with 2 fields:
S = struct('A', 1, 'B', 2);
Want = struct('B', 2);
R = fRMField(S, 'A');
if isequal(R, Want)
   disp('  ok: remove ''A'' from S.(A,B)');
else
   error([FuncName, ': Remove ''A'' from S.(A,B)']);
end

R = fRMField(S, {'A'});
if isequal(R, Want)
   disp('  ok: remove {''A''} from S.(A,B)');
else
   error([FuncName, ': Remove {''A''} from S.(A,B)']);
end

R = fRMField(S, {'A', 'field'});
if isequal(R, Want)
   disp('  ok: remove {''A'', ''field''} from S.(A,B)');
else
   error([FuncName, ': Remove {''A'', ''field''} from S.(A,B)']);
end

R = fRMField(S, {'field', 'A'});
if isequal(R, Want)
   disp('  ok: remove {''field'', ''A''} from S.(A,B)');
else
   error([FuncName, ': Remove {''field'', ''A''} from S.(A,B)']);
end

R = fRMField(S, {'A', 'B'});
if isempty(Xfieldnames(R))
   disp('  ok: remove {''A'', ''B''} from S.(A,B)');
else
   error([FuncName, ': Remove {''A'', ''B''} from S.(A,B)']);
end

R = fRMField(S, {'B', 'A'});
if isempty(Xfieldnames(R))
   disp('  ok: remove {''B'', ''A''} from S.(A,B)');
else
   error([FuncName, ': Remove {''B'', ''A''} from S.(A,B)']);
end

R = fRMField(S, {'A', 'B', 'field'});
if isempty(Xfieldnames(R))
   disp('  ok: remove {''A'', ''B'', ''field''} from S.(A,B)');
else
   error([FuncName, ': Remove {''A'', ''B'', ''field''} from S.(A,B)']);
end

R = fRMField(S, {'B', 'field', 'A'});
if isempty(Xfieldnames(R))
   disp('  ok: remove {''B'', ''field'', ''A''} from S.(A,B)');
else
   error([FuncName, ': Remove {''B'', ''field'', ''A''} from S.(A,B)']);
end

% Struct array:
S    = struct('A', {1, 11}, 'B', {2, 22});
Want = struct('B', {2, 22});
R    = fRMField(S, 'A');
if isequal(R, Want)
   disp('  ok: remove ''A'' from S(1:2).(A,B)');
else
   error([FuncName, ': Remove ''A'' from S(1:2).(A,B)']);
end

R = fRMField(S, {'A'});
if isequal(R, Want)
   disp('  ok: remove {''A''} from S(1:2).(A,B)');
else
   error([FuncName, ': Remove {''A''} from S(1:2).(A,B)']);
end

R = fRMField(S, {'A', 'field'});
if isequal(R, Want)
   disp('  ok: remove {''A'', ''field''} from S(1:2).(A,B)');
else
   error([FuncName, ': Remove {''A'', ''field''} from S(1:2).(A,B)']);
end

R = fRMField(S, {'field', 'A'});
if isequal(R, Want)
   disp('  ok: remove {''field'', ''A''} from S(1:2).(A,B)');
else
   error([FuncName, ': Remove {''field'', ''A''} from S(1:2).(A,B)']);
end

R = fRMField(S, {'A', 'B'});
if isempty(Xfieldnames(R))
   disp('  ok: remove {''A'', ''B''} from S(1:2).(A,B)');
else
   error([FuncName, ': Remove {''A'', ''B''} from S(1:2).(A,B)']);
end

R = fRMField(S, {'B', 'A'});
if isempty(Xfieldnames(R))
   disp('  ok: remove {''B'', ''A''} from S(1:2).(A,B)');
else
   error([FuncName, ': Remove {''B'', ''A''} from S(1:2).(A,B)']);
end

R = fRMField(S, {'A', 'B', 'field'});
if isempty(Xfieldnames(R))
   disp('  ok: remove {''A'', ''B'', ''field''} from S(1:2).(A,B)');
else
   error([FuncName, ...
         ': Remove {''A'', ''B'', ''field''} from S(1:2).(A,B)']);
end

R = fRMField(S, {'B', 'field', 'A'});
if isempty(Xfieldnames(R))
   disp('  ok: remove {''B'', ''field'', ''A''} from S(1:2).(A,B)');
else
   error([FuncName, ...
         ': Remove {''B'', ''field'', ''A''} from S(1:2).(A,B)']);
end

% ------------------------------------------------------------------------------
fprintf('\n== Test Speed:\n');
minT = eps;

% Find a suiting number of loops:
S = struct('A', 1, 'B', zeros(1, 100), 'C', ones(100, 100));
if doSpeed
   iLoop     = 0;
   startTime = cputime;
   while cputime - startTime < 1.0
      v     = fRMField(S, 'A'); %#ok<NASGU>
      clear('v');
      iLoop = iLoop + 1;
   end
   nDigit = max(1, floor(log10(max(1, iLoop))) - 1);
   nLoops = max(2, round(iLoop / 10 ^ nDigit) * 10 ^ nDigit);
else
   disp('  Reduced speed measurement - displayed times are meaningless!');
   nLoops = 2;
end

S = struct('A', 1, 'B', zeros(1, 100), 'C', ones(100, 100));

tic;
for i = 1:nLoops
%    v = rmfield(S, 'C'); %#ok<NASGU>
   v =  fast_rmfield(S,'C');
   clear('v');
end
etM = toc + minT;

tic;
for i = 1:nLoops
   v = fRMField(S, 'C'); %#ok<NASGU>
   clear('v');
end
etOpt = toc + minT;

fprintf(['  Remove 1 field from Struct with 3 fields (%d loops):\n', ...
      '    RMFIELD:  %.2f sec\n', ...
      '    fRMField: %.2f sec  ==>  %.1f%% of RMFIELD\n\n'], ...
   nLoops, etM, etOpt, 100 * etOpt / etM);

% ------------------------------
nField = 100;
Field  = cell(nField, 1);
Data   = cell(nField, 1);
for i = 1:nField
   Field{i} = sprintf('Field%.3d', i);
   Data{i}  = zeros(10);
end
S = cell2struct(Data, Field);

if doSpeed
   iLoop     = 0;
   startTime = cputime;
   while cputime - startTime < 1.0
      for j = 1:nField
%          v = rmfield(S, Field{j});  %#ok<NASGU>
        v = fast_rmfield(S, Field{j});
         clear('v');
      end
      iLoop = iLoop + 1;
   end
   nLoops = ceil(iLoop / (cputime - startTime));
else
   nLoops = 2;
end

tic;
for i = 1:nLoops
   for j = 1:nField
%       v = rmfield(S, Field{j});  %#ok<NASGU>
      v = fast_rmfield(S, Field{j});
      clear('v');
   end
end
etM = toc + minT;

tic;
for i = 1:nLoops
   for j = 1:nField
      v = fRMField(S, Field{j});  %#ok<NASGU>
      clear('v');
   end
end
etOpt = toc + minT;

fprintf(['  Remove 1 field from Struct with %d fields (%d loops):\n', ...
      '    RMFIELD:  %.2f sec\n', ...
      '    fRMField: %.2f sec  ==>  %.1f%% of RMFIELD\n\n'], ...
   nField, nLoops, etM, etOpt, 100 * etOpt / etM);

% -----------------------------
remove = Field(1:2:end);
nLoops = nLoops * 50;

tic;
for i = 1:nLoops
%    v = rmfield(S, remove);  %#ok<NASGU>
    v = fast_rmfield(S, remove);
   clear('v');
end
etM = toc + minT;

tic;
for i = 1:nLoops
   v = fRMField(S, remove);  %#ok<NASGU>
   clear('v');
end
etOpt = toc + minT;

fprintf(['  Remove %d field from Struct with %d fields (%d loops):\n', ...
      '    RMFIELD:  %.2f sec\n', ...
      '    fRMField: %.2f sec  ==>  %.1f%% of RMFIELD\n\n'], ...
   length(remove), nField, nLoops, etM, etOpt, 100 * etOpt / etM);

% Bye:
fprintf('== fRMField seems to work well.\n');

return;

% ******************************************************************************
function F = Xfieldnames(S)
% Reply fieldnames and {} if input is []:

if isa(S, 'struct')
   F = fieldnames(S);
elseif isempty(S)
   F = {};
else
   error('TestfRMField(Xfieldnames): neither struct nor []?!');
end

return;
