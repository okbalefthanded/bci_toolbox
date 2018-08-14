function uTest_CStr2String(doSpeed)
% Automatic test: CStr2String
% This is a routine for automatic testing. It is not needed for processing and
% can be deleted or moved to a folder, where it does not bother.
%
% uTest_CStr2String(doSpeed)
% INPUT:
%   doSpeed: Optional logical flag to trigger time consuming speed tests.
%            Default: TRUE. If no speed test is defined, this is ignored.
% OUTPUT:
%   On failure the test stops with an error.
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP
% Author: Jan Simon, Heidelberg, (C) 2009-2010 matlab.THISYEAR(a)nMINUSsimon.de

% $JRev: R0n V:013 Sum:ydtvkk3U5M/T Date:22-Sep-2010 02:30:25 $
% $License: BSD (see Docs\BSD_License.txt) $
% $File: Tools\UnitTests_\uTest_CStr2String.m $
% History:
% 007: 01-Apr-2010 22:44, No shared copy data for testing!
%      Using "C=cell(1E3,1),C(:)={'String'}" does not duplicate the string, but
%      creates shared data copies. This accelerates CStr2String and slows down
%      CAT. Now the test data are filled with different strings.
%      Mysterious: On Matlab 2009a the JIT acceleration works much better if
%      CStr2String is called with a 2nd input:
%      Fast: for i=1:10000;
%               v = CStr2String(C, '');
%               clear('v');
%            end
%      Slow: for i=1:10000;             30% slower !!!
%               v = CStr2String(C);     Same branch inside the Mex!!!
%               clear('v');
%            end
%      The difference disappears, if the CLEAR is moved in the same line as the
%      CStr2String.

% Initialize: ==================================================================
ErrID = ['JSim:', mfilename];
LF = char(10);

% Default for the input:
if nargin == 0
   doSpeed = true;
end

% Times for testing:
if doSpeed
   randDelay = 5;    % [sec], time for random tests
   SpeedTime = 1.0;  % [sec], time for speed tests
else
   randDelay = 0.5;
   SpeedTime = 0.25;
end
TestTime = 0.2;  % Get number of loops

% Hello:
whichFunc = which('CStr2String');
disp(['==== Test CStr2String:  ', datestr(now, 0), LF, ...
      'Version: ', whichFunc, LF]);

% Determine if the MEX or M-version is called:
[dummy1, dummy2, fileExt] = fileparts(whichFunc);  %#ok<ASGLU>
useMex = strcmpi(strrep(fileExt, '.', ''), mexext);

% Start tests: -----------------------------------------------------------------
% Standard tests - empty input, cell without populated elements, small known
% answer test:
S = CStr2String({});
if isempty(S) && ischar(S)
   disp('  ok: empty cell');
else
   error(ErrID, 'Failed for empty cell.');
end
   
S = CStr2String(cell(1, 1));
if isempty(S) && ischar(S)
   disp('  ok: {NULL}');
else
   error(ErrID, 'Failed for {NULL}.');
end

S = CStr2String(cell(1, 2));
if isempty(S) && ischar(S)
   disp('  ok: {NULL, NULL}');
else
   error(ErrID, 'Failed for {NULL, NULL}.');
end

S = CStr2String({''});
if isempty(S) && ischar(S)
   disp('  ok: {''''}');
else
   error(ErrID, 'Failed for {''''}.');
end

S = CStr2String({'', ''});
if isempty(S) && ischar(S)
   disp('  ok: {'''', ''''}');
else
   error(ErrID, 'Failed for {'''', ''''}.');
end

S = CStr2String({'S'});
if isequal(S, 'S')
   disp('  ok: {''S''}');
else
   error(ErrID, 'Failed for {''S''}.');
end

S = CStr2String({'S1', 'S2'});
if isequal(S, 'S1S2')
   disp('  ok: {''S1'', ''S2''}');
else
   error(ErrID, 'Failed for {''S1'', ''S2''}.');
end

S = CStr2String({'S'; 'T'; 'UV'});
if isequal(S, 'STUV')
   disp('  ok: {''S''; ''T''; ''UV''}');
else
   error(ErrID, 'Failed for {''S''; ''T''; ''UV''}.');
end

S = CStr2String({'AAA', 'BB', [], 'C'});
if isequal(S, 'AAABBC')
   disp('  ok: {''AAA''; ''BB''; [], ''C''}');
else
   error(ErrID, 'Failed for {''AAA''; ''BB''; [], ''C''}.');
end

% 2nd input:
S = CStr2String({}, '|');
if isempty(S) && ischar(S)
   disp('  ok: empty cell, ''|''');
else
   error(ErrID, 'Failed for empty cell, ''|''.');
end
   
S = CStr2String(cell(1, 1), '|');
if isequal(S, '|')
   disp('  ok: {NULL}, ''|''');
else
   error(ErrID, 'Failed for {NULL}, ''|''.');
end

S = CStr2String(cell(1, 2), '|');
if isequal(S, '||')
   disp('  ok: {NULL, NULL}, ''|''');
else
   error(ErrID, 'Failed for {NULL, NULL}, ''|''.');
end

S = CStr2String({''}, '|');
if isequal(S, '|')
   disp('  ok: {''''}, ''|''');
else
   error(ErrID, 'Failed for {''''}, ''|''.');
end

S = CStr2String({'', ''}, '|');
if isequal(S, '||')
   disp('  ok: {'''', ''''}, ''|''');
else
   error(ErrID, 'Failed for {'''', ''''}, ''|''.');
end

S = CStr2String({'S'}, '|');
if isequal(S, 'S|')
   disp('  ok: {''S''}, ''|''');
else
   error(ErrID, 'Failed for {''S''}, ''|''.');
end

S = CStr2String({'S1', 'S2'}, '|');
if isequal(S, 'S1|S2|')
   disp('  ok: {''S1'', ''S2''}, ''|''');
else
   error(ErrID, 'Failed for {''S1'', ''S2''}, ''|''.');
end

S = CStr2String({'S'; 'T'; 'UV'}, '|');
if isequal(S, 'S|T|UV|')
   disp('  ok: {''S''; ''T''; ''UV''}, ''|''');
else
   error(ErrID, 'Failed for {''S''; ''T''; ''UV''}, ''|''.');
end

S = CStr2String({'AAA', 'BB', [], 'C'}, '#+');
if isequal(S, 'AAA#+BB#+#+C#+')
   disp('  ok: {''AAA''; ''BB''; [], ''C''}, ''#+''');
else
   error(ErrID, 'Failed for {''AAA''; ''BB''; [], ''C''}, ''#+''.');
end

S = CStr2String({'1', '2'; '3', '4'}, '');
if isequal(S, '1324')
   disp('  ok: {''1'', ''2''; ''3'', ''4''}, ''''');
else
   error(ErrID, 'Failed for {''1'', ''2''; ''3'', ''4''}, ''''.');
end

S = CStr2String({}, '', 'noTrail');
if isequal(S, '')
   disp('  ok: {}, '''', noTrail');
else
   error(ErrID, 'Failed for {}, '''', noTrail.');
end

S = CStr2String({}, '', 'Trail');
if isequal(S, '')
   disp('  ok: {}, '''', Trail');
else
   error(ErrID, 'Failed for {}, '''', Trail.');
end

S = CStr2String({}, '#', 'noTrail');
if isequal(S, '')
   disp('  ok: {}, #, noTrail');
else
   error(ErrID, 'Failed for {}, #, noTrail.');
end

S = CStr2String({}, '#', 'Trail');
if isequal(S, '')
   disp('  ok: {}, #, Trail');
else
   error(ErrID, 'Failed for {}, #, Trail.');
end

S = CStr2String({'a'}, '#', 'noTrail');
if isequal(S, 'a')
   disp('  ok: {a}, #, noTrail');
else
   error(ErrID, 'Failed for {a}, #, noTrail.');
end

S = CStr2String({'a'}, '#', 'Trail');
if isequal(S, 'a#')
   disp('  ok: {a}, #, Trail');
else
   error(ErrID, 'Failed for {a}, #, Trail.');
end

S = CStr2String({'a', 'b'}, '#', 'noTrail');
if isequal(S, 'a#b')
   disp('  ok: {a, b}, #, noTrail');
else
   error(ErrID, 'Failed for {a, b}, #, noTrail.');
end

S = CStr2String({'a', 'b'}, '#', 'Trail');
if isequal(S, 'a#b#')
   disp('  ok: {a, b}, #, Trail');
else
   error(ErrID, 'Failed for {a, b}, #, Trail.');
end

S = CStr2String({'a', 'bb', 'ccc'}, '##', 'noTrail');
if isequal(S, 'a##bb##ccc')
   disp('  ok: {a, bb, ccc}, ##, noTrail');
else
   error(ErrID, 'Failed for {a, bb, ccc}, ##, noTrail.');
end

S = CStr2String({'a', 'bb', 'ccc'}, '##', 'Trail');
if isequal(S, 'a##bb##ccc##')
   disp('  ok: {a, bb, ccc}, ##, Trail');
else
   error(ErrID, 'Failed for {a, bb, ccc}, ##, Trail.');
end

% Random tests: ----------------------------------------------------------------
fprintf('\n== Random tests (%g sec):\n', randDelay);
DataC    = strread(sprintf('%d,', fix(1000 .^ rand(1, 100))), ...
   '%s', 'delimiter', ',');
lenDataC = length(DataC);

iniTime = cputime;
nTest   = 0;
while cputime - iniTime < randDelay
   for N = 0:99
      C = DataC(fix(rand(1, N) * lenDataC) + 1);
      if ~strcmp(CStr2String_L(C), CStr2String(C))
         error(ErrID, 'Failed for random test.');
      end
      
      if ~strcmp(CStr2String_L(C, '#'), CStr2String(C, '#'))
         error(ErrID, 'Failed for random test with separator.');
      end
   end
   nTest = nTest + 100;
end
fprintf('  ok: %d random tests passed.\n', nTest);

% Invalid input: ---------------------------------------------------------------
fprintf('\n== Check rejection of bad input:\n');
tooLazy = false;

try
   dummy   = CStr2String([]);
   tooLazy = true;
catch
   disp(['  ok: [] rejected: ', LF, '      ', strrep(lasterr, LF, '; ')]);
end
if tooLazy
   error(ErrID, '[] not rejected.');
end

if useMex  % Less checks of inputs in M-version:
   try
      dummy   = CStr2String({1});
      tooLazy = true;
   catch
      disp(['  ok: {1} rejected: ', LF, '      ', strrep(lasterr, LF, '; ')]);
   end
   if tooLazy
      error(ErrID, '{1} not rejected.');
   end
   
   try
      dummy   = CStr2String({'1', 2});
      tooLazy = true;
   catch
      disp(['  ok: {''1'', 2} rejected: ', LF, '      ', ...
         strrep(lasterr, LF, '; ')]);
   end
   if tooLazy
      error(ErrID, '{''1'', 2} not rejected.');
   end
   
   try
      dummy   = CStr2String({'1'}, []);
      tooLazy = true;
   catch
      disp(['  ok: ({''1''}, []) rejected: ', LF, '      ', ...
         strrep(lasterr, LF, '; ')]);
   end
   if tooLazy
      error(ErrID, '({''1''}, []) not rejected.');
   end
   
   try
      dummy   = CStr2String({'1'}, '#', struct('asd', 'bsd'));
      tooLazy = true;
   catch
      disp(['  ok: ({''1''}, ''#'', STRUCT) rejected: ', LF, '      ', ...
            strrep(lasterr, LF, '; ')]);
   end
   if tooLazy
      error(ErrID, '({''1''}, ''#'', STRUCT) not rejected.');
   end
   
   try
      dummy   = CStr2String({['1'; '2']});
      tooLazy = true;
   catch
      disp(['  ok: ({[''1''; ''2'']}) rejected: ', LF, '      ', ...
            strrep(lasterr, LF, '; ')]);
   end
   if tooLazy
      error(ErrID, '({[''1''; ''2'']}) not rejected.');
   end
   
   try
      dummy   = CStr2String({['1'; '2']}, '#');
      tooLazy = true;
   catch
      disp(['  ok: ({[''1''; ''2'']}, ''#'') rejected: ', LF, '      ', ...
            strrep(lasterr, LF, '; ')]);
   end
   if tooLazy
      error(ErrID, '({[''1''; ''2'']}, ''#'') not rejected.');
   end
else
   disp('  ?:  Reduced input checks for M-version');
end

% Speed: -----------------------------------------------------------------------
if doSpeed
   fprintf('\n== Speed test (test time: %g sec):\n', SpeedTime);
else
   fprintf('\n== Speed test (test time: %g sec - may be inaccurate):\n', ...
      SpeedTime);
end
drawnow;  % Allow update of external events

CellLen = [5, 10, 100, 1000, 10000];
DataLen = [1, 10, 100];
fprintf('  Cell length:         ');
fprintf('%9d', CellLen);
fprintf('\n');
aChar = 'a';
for aDataLen = DataLen
   fprintf('  String lengths: %d\n', aDataLen);
   
   fprintf('    SPRINTF(%%s, C{:})  ');
   for aCellLen = CellLen
      CStr = cell(1, aCellLen);
      for iC = 1:aCellLen
         CStr{iC} = aChar(ones(1, aDataLen));
      end
      
      % Get number of loops (the WHILE CPUTIME loop has more overhead):
      iTime = cputime;
      N = 0;
      while cputime - iTime < TestTime
         S = sprintf('%s', CStr{:});  clear('S');  %#ok<*NASGU>
         N = N + 1;
      end
      N = max(1, round(N / (cputime - iTime) * SpeedTime));

      % The actual test:
      tic;
      for iN = 1:N
         S = sprintf('%s', CStr{:});  clear('S');
      end
      NPerSec = N / (toc + eps);  % Loops per second
      PrintLoop(NPerSec);
      drawnow;  % Allow update of external events
   end
   fprintf('  loops/sec\n');

   fprintf('    SPRINTF(%%s#, C{:}) ');
   for aCellLen = CellLen
      CStr = cell(1, aCellLen);
      for iC = 1:aCellLen
         CStr{iC} = aChar(ones(1, aDataLen));
      end
      
      % Get number of loops (the WHILE CPUTIME loop has more overhead):
      iTime = cputime;
      N = 0;
      while cputime - iTime < TestTime
         sprintf('%sSep', CStr{:});  clear('S');
         N = N + 1;
      end
      N = max(1, round(N / (cputime - iTime) * SpeedTime));
      
      % The actual test:
      tic;
      for iN = 1:N
         S = sprintf('%sSep', CStr{:});  clear('S');
      end
      NPerSec = N / (toc + eps);  % Loops per second
      PrintLoop(NPerSec);
      drawnow;  % Allow update of external events
   end
   fprintf('  loops/sec\n');

   fprintf('    CAT(2, C{:})       ');
   for aCellLen = CellLen
      CStr = cell(1, aCellLen);
      for iC = 1:aCellLen
         CStr{iC} = aChar(ones(1, aDataLen));
      end
      
      % Get number of loops (the WHILE CPUTIME loop has more overhead):
      iTime = cputime;
      N = 0;
      while cputime - iTime < TestTime
         S = cat(2, CStr{:});    clear('S');
         N = N + 1;
      end
      N = max(1, round(N / (cputime - iTime) * SpeedTime));
      
      % The actual test:
      tic;
      for iN = 1:N
         S = cat(2, CStr{:});    clear('S');
      end
      NPerSec = N / (toc + eps);  % Loops per second
      PrintLoop(NPerSec);
      drawnow;  % Allow update of external events
   end
   fprintf('  loops/sec\n');
   
   % ********
   fprintf('    [C{:}]  (HORZCAT!) ');
   for aCellLen = CellLen
      CStr = cell(1, aCellLen);
      for iC = 1:aCellLen
         CStr{iC} = aChar(ones(1, aDataLen));
      end
      
      % Get number of loops (the WHILE CPUTIME loop has more overhead):
      iTime = cputime;
      N = 0;
      while cputime - iTime < TestTime
         S = [CStr{:}];    clear('S');
         N = N + 1;
      end
      N = max(1, round(N / (cputime - iTime) * SpeedTime));
      
      % The actual test:
      tic;
      for iN = 1:N
         S = [CStr{:}];    clear('S');
      end
      NPerSec = N / (toc + eps);  % Loops per second
      PrintLoop(NPerSec);
      drawnow;  % Allow update of external events
   end
   fprintf('  loops/sec\n');
   
   % *********
   fprintf('    CStr2String(C)     ');
   for aCellLen = CellLen
      CStr = cell(1, aCellLen);
      for iC = 1:aCellLen
         CStr{iC} = aChar(ones(1, aDataLen));
      end
      
      % Get number of loops (the WHILE CPUTIME loop has more overhead):
      iTime = cputime;
      N = 0;
      while cputime - iTime < TestTime
         S = CStr2String(CStr);  clear('S');
         N = N + 1;
      end
      N = max(1, round(N / (cputime - iTime) * SpeedTime));
      
      % The actual test:
      tic;
      for iN = 1:N
         S = CStr2String(CStr);  clear('S');
      end
      NPerSec = N / (toc + eps);  % Loops per second
      PrintLoop(NPerSec);
      drawnow;  % Allow update of external events
   end
   fprintf('  loops/sec\n');
   
   fprintf('    CStr2String(C, #)  ');
   for aCellLen = CellLen
      Sep  = 'Sep';
      CStr = cell(1, aCellLen);
      for iC = 1:aCellLen
         CStr{iC} = aChar(ones(1, aDataLen));
      end
      
      % Get number of loops (the WHILE CPUTIME loop has more overhead):
      iTime = cputime;
      N = 0;
      while cputime - iTime < TestTime
         S = CStr2String(CStr, Sep);  clear('S');
         N = N + 1;
      end
      N = max(1, round(N / (cputime - iTime) * SpeedTime));
      
      % The actual test:
      tic;
      for iN = 1:N
         S = CStr2String(CStr, Sep);  clear('S');
      end
      NPerSec = N / (toc + eps);  % Loops per second
      PrintLoop(NPerSec);
      drawnow;  % Allow update of external events
   end
   fprintf('  loops/sec\n');
end

disp([char(10), 'CStr2String seems to work fine']);

return;

% ******************************************************************************
function PrintLoop(N)
if N > 10
   fprintf('  %7.0f', N);
else
   fprintf('  %7.1f', N);
end

return;

% ******************************************************************************
function String = CStr2String_L(CStr, Sep)
% Concatenate strings of a cell string - direct Matlab approach

if nargin == 1
   String = cat(2, CStr{:});
else
   String = sprintf(['%s', Sep], CStr{:});
end

if isempty(String)
   String = '';
end
   
return;
