function TestCStrCatStr(doSpeed)
% Automatic test: CStrCatStr
% This is a routine for automatic testing. It is not needed for processing and
% can be deleted or moved to a folder, where it does not bother.
%
% TestCStrCatStr(doSpeed)
% INPUT:
%   doSpeed: Optional logical flag to trigger time consuming speed tests.
%            Default: TRUE. If no speed test is defined, this is ignored.
% OUTPUT:
%   On failure the test stops with an error.
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP
% Author: Jan Simon, Heidelberg, (C) 2009-2010 matlab.THISYEAR(a)nMINUSsimon.de

% $JRev: R0n V:030 Sum:wP60U9hy0/Ja Date:11-Feb-2010 01:28:24 $
% $File: Published\CStrCatStr\TestCStrCatStr.m $
% $History:
% 021: 07-May-2009 09:24, Check 3 inputs also.
% 027: 12-Sep-2009 16:20, Check handling uf NULL elements.
% 028: 25-Oct-2009 16:09, BUGFIX: Checks of rejected bad input failed.
%      Not rejected bad inputs called ERROR, but this was masked by a TRY-CATCH
%      block. The function CStrCatStr was not affected.

% Initialize: ==================================================================
% Global Interface: ------------------------------------------------------------
% Initial values: --------------------------------------------------------------
% Program Interface: -----------------------------------------------------------
if nargin == 0
   doSpeed = true;
end

% Reduce time to measure speed of STRCAT:
ExtrapolateSTRCAT = true;

% User Interface: --------------------------------------------------------------
% Do the work: =================================================================
whichFun = which('CStrCatStr');
disp(['==== Test CStrCatStr ', datestr(now, 0), char(10), ...
   '  Version: ', whichFun, char(10)]);
pause(0.001);
[dum1, dum2, typeFun] = fileparts(whichFun); %#ok<ASGLU>
typeFun(findstr(typeFun, '.')) = [];

% Set of test strings: ---------------------------------------------------------
S  = {'', 'a', 'ab', 'abc', 'abcdefghijklmnop'};
nS = length(S);
SR = S(nS:-1:1);
C  = {{}, {''}, {'', ''}, {'', '', ''}, ...
   {'a'}, {'ab'}, {'abc'}, ...
   {'a', ''}, {'', 'a'}, {'a', 'b'}, {'a', 'b', ''}, ...
   {'ab', ''}, {'', 'ab'}, {'ab', 'bb'}, {'ab', 'bb', 'b'}, ...
   S, SR};

% Two inputs: ------------------------------------------------------------------
% Compare combinations of test strings with result from STRCAT - consider the
% different replies for empty cells:
fprintf(['  2 inputs: Combinations of ', ShowStr(S), ': ']);
for i1 = 1:nS
   for i2 = 1:nS
      % String + scalar cell:
      CheckMex(S{i1}, S(i2));
      
      % Scalar cell + string:
      CheckMex(S(i1), S{i2});
      
      % Scalar cell + scalar cell:
      CheckMex(S(i1), S(i2));
   end
   
   % Cell + string:
   CheckMex(S, S{i1});
   
   % String + Cell:
   CheckMex(S{i1}, S);
   
   % String + Cell 2:
   for iC = 1:length(C)
      CheckMex(S{i1}, C{iC});
   end
end

% Cell + cell:
CheckMex(S,  S);
CheckMex(SR, S);
CheckMex(S,  SR);
CheckMex(SR, SR);

fprintf('ok\n');

% 3 inputs: --------------------------------------------------------------------
fprintf(['  3 inputs: Combinations of ', ShowStr(S), ': ']);

% Cell + cell:
for Bin = 0:7
   % Test strings and scalar cells:
   if Bin ~= 0  % At least one must be a cell
      for i1 = 1:nS
         for i2 = 1:nS
            for i3 = 1:nS
               v = [i1, i2, i3];
               for iBin = 1:3
                  if bitget(Bin, iBin)
                     SB{iBin} = S(v(iBin));  %#ok<AGROW>
                  else
                     SB{iBin} = S{v(iBin)};  %#ok<AGROW>
                  end
               end
               
               CheckMex(SB{1}, SB{2}, SB{3});
            end  % for i3
         end  % for i2
      end  % for i1
   end
   
   % Test all combinations of S and reverted S:
   for iBin = 1:3
      if bitget(Bin, iBin)
         SB{iBin} = S;   %#ok<AGROW>
      else
         SB{iBin} = SR;  %#ok<AGROW>
      end
   end
   
   CheckMex(SB{1}, SB{2}, SB{3});
end

fprintf('ok\n');

% Random tests and comparison with STRCAT: -------------------------------------
startTime = cputime;
count     = 0;
TestTime  = 1 + 4 * double(doSpeed);  % 1 or 5 seconds
fprintf('  Random inputs compared with STRCAT (%g sec): ', TestTime);
while cputime - startTime < TestTime
   count = count + 1;
   if rand < 2/7  % 2 inputs:
      switch fix(rand * 3)
         case 0
            A = RandStr('char');
            B = RandStr('cell', []);
         case 1
            A = RandStr('cell', []);
            B = RandStr('char');
         case 2
            A = RandStr('cell', []);
            B = RandStr('cell', size(A));
      end
      
      mexCat = CStrCatStr(A, B);
      matCat = strcat(A, B);
      
   else  % 3 inputs:
      switch fix(rand * 7)
         case 0
            A = RandStr('cell', []);
            B = RandStr('char');
            C = RandStr('char');
         case 1
            A = RandStr('char');
            B = RandStr('cell',[]);
            C = RandStr('char');
         case 2
            A = RandStr('char');
            B = RandStr('char');
            C = RandStr('cell', []);
         case 3
            A = RandStr('cell', []);
            B = RandStr('cell', size(A));
            C = RandStr('char');
         case 4
            A = RandStr('cell', []);
            B = RandStr('char');
            C = RandStr('cell', size(A));
         case 5
            A = RandStr('char');
            B = RandStr('cell', []);
            C = RandStr('cell', size(B));
         case 6
            A = RandStr('cell', []);
            B = RandStr('cell', size(A));
            C = RandStr('cell', size(A));
      end
      
      mexCat = CStrCatStr(A, B, C);
      matCat = strcat(A, B, C);
   end
   
   % STRCAT('', {''}) replies [1 x 0] char:
   matCat(cellfun('isempty', matCat)) = {''};
   
   if isequal(mexCat, matCat) == 0
      disp([char(10), 'CStrCatStr:']);
      disp(mexCat);
      disp('STRCAT:');
      disp(matCat);
      error(['*** ', mfilename, ': Failed for random tests']);
   end
end
fprintf('%d tests ok\n', count);

% Test bad inputs: -------------------------------------------------------------
disp([char(10), '  Provoke errors:']);
errBak  = lasterr;
tooLazy = false;
try
   V = CStrCatStr('string', 'string');  %#ok<*NASGU>
   tooLazy = true;
catch
   disp('  Ok: 2 strings refused.');
end
if tooLazy
   error(['*** ', mfilename, ': 2 strings accepted?!']);
end

try
   V = CStrCatStr({'1', '2'}, {'1'});
   tooLazy = true;
catch
   disp('  Ok: Cells of different size refused (1, 2).');
end
if tooLazy
   error(['*** ', mfilename, ': Cells of different size accepted?!']);
end

try
   V = CStrCatStr('string', 'string', 'string');
   tooLazy = true;
catch
   disp('  Ok: 3 strings refused.');
end
if tooLazy
   error(['*** ', mfilename, ': 2 strings accepted?!']);
end

try
   V = CStrCatStr({'1', '2'}, {'1'}, {'1'});
   tooLazy = true;
catch
   disp('  Ok: Cells of different size refused (2, 1, 1).');
end
if tooLazy
   error(['*** ', mfilename, ': Cells of different size accepted?!']);
end

try
   V = CStrCatStr({'1'}, {'1', '2'}, {'1'});
   tooLazy = true;
catch
   disp('  Ok: Cells of different size refused (1, 2, 1).');
end
if tooLazy
   error(['*** ', mfilename, ': Cells of different size accepted?!']);
end

try
   V = CStrCatStr({'1'}, {'1'}, {'1', '2'});
   tooLazy = true;
catch
   disp('  Ok: Cells of different size refused (1, 1, 2).');
end
if tooLazy
   error(['*** ', mfilename, ': Cells of different size accepted?!']);
end

try
   V = CStrCatStr({'1', '2'}, 'string', {'1'});
   tooLazy = true;
catch
   disp('  Ok: Cells of different size refused (cell, string, cell).');
end
if tooLazy
   error(['*** ', mfilename, ': Cells of different size accepted?!']);
end

try
   V = CStrCatStr({'1'}, {'1', '2'}, 'string');
   tooLazy = true;
catch
   disp('  Ok: Cells of different size refused (cell, cell, string).');
end
if tooLazy
   error(['*** ', mfilename, ': Cells of different size accepted?!']);
end

try
   V = CStrCatStr('string', {'1'}, {'1', '2'});
   tooLazy = true;
catch
   disp('  Ok: Cells of different size refused (string, cell, cell).');
end
if tooLazy
   error(['*** ', mfilename, ': Cells of different size accepted?!']);
end

% The mex version checks if elements are strings:
if strcmpi(typeFun, mexext)
   % 2 inputs:
   InputList1 = {'string', {'cell'}; {'cell'}, 'string'; {'cell'}, {'cell'}};
   for i1 = 1:size(InputList1, 1)
      aInput = InputList1(i1, :);
      for i2 = 1:2
         bInput = aInput;
         if ischar(bInput{i2})
            bInput{i2} = 0;
         else
            bInput{i2} = {0};
         end
         
         try
            V = CStrCatStr(bInput{:});
            tooLazy = true;
         catch  % do nothing
         end
         if tooLazy
            disp(bInput);
            error(['*** ', mfilename, ': Non-string input accepted?!']);
         end
      end
   end
   
   % Not initialized cell elements must be refused:
   Cell0      = cell(1, 1);
   Cell0x     = cell(1, 3);
   Cell0x{1}  = 'asd';
   Cell0x{3}  = 'bsd';
   InputList2 = {Cell0, Cell0x};
   
   for iType = 1:2
      aCell = InputList2{iType};
      try
         V = CStrCatStr('string', aCell);
         tooLazy = true;
      catch  % do nothing
      end
      if tooLazy
         error(['*** ', mfilename, ': NULL accepted?!']);
      end
      
      try
         V = CStrCatStr(aCell, 'string');
         tooLazy = true;
      catch  % do nothing
      end
      if tooLazy
         error(['*** ', mfilename, ': NULL accepted?!']);
      end
      
      try
         V = CStrCatStr(aCell, aCell);
         tooLazy = true;
      catch  % do nothing
      end
      if tooLazy
         error(['*** ', mfilename, ': NULL accepted?!']);
      end
   end
   
   % 3 inputs:
   InputList3 = {{'cell'}, 'string', 'string'; ...
      'string', {'cell'}, 'string'; ...
      'string', 'string', {'cell'}; ...
      {'cell'}, 'string', {'cell'}; ...
      {'cell'}, {'cell'}, 'string'; ...
      'string', {'cell'}, {'cell'}; ...
      {'cell'}, {'cell'}, {'cell'}};
   
   for i1 = 1:size(InputList3, 1)
      aInput = InputList3(i1, :);
      for i2 = 1:3
         bInput = aInput;
         if ischar(bInput{i2})
            bInput{i2} = 0;
         else
            bInput{i2} = {0};
         end
         
         try
            V = CStrCatStr(bInput{:});
            tooLazy = true;
         catch  % do nothing
         end
         if tooLazy
            disp(bInput);
            error(['*** ', mfilename, ': Non-string input accepted?!']);
         end
      end
   end
   
   InputList4 = {{'scalar_cell'}, {'cell1', 'cell2'}, 'string'};
   for iType = 1:length(InputList4)
      aCell = InputList4{iType};
      try
         V = CStrCatStr('A', 'B', aCell);
         if ~iscell(aCell)
            tooLazy = true;
         end
      catch  % do nothing
      end
      if tooLazy
         error(['*** ', mfilename, ': NULL accepted?!']);
      end
      
      try
         V = CStrCatStr('A', aCell, 'C');
         if ~iscell(aCell)
            tooLazy = true;
         end
      catch  % do nothing
      end
      if tooLazy
         error(['*** ', mfilename, ': NULL accepted?!']);
      end
      
      try
         V = CStrCatStr(aCell, 'B', 'C');
         if ~iscell(aCell)
            tooLazy = true;
         end
      catch  % do nothing
      end
      if tooLazy
         error(['*** ', mfilename, ': NULL accepted?!']);
      end
      
      try
         V = CStrCatStr('A', aCell, aCell);
         if ~iscell(aCell)
            tooLazy = true;
         end
      catch  % do nothing
      end
      if tooLazy
         error(['*** ', mfilename, ': NULL accepted?!']);
      end
      
      try
         V = CStrCatStr(aCell, 'B', aCell);
         if ~iscell(aCell)
            tooLazy = true;
         end
      catch  % do nothing
      end
      if tooLazy
         error(['*** ', mfilename, ': NULL accepted?!']);
      end
      
      try
         V = CStrCatStr(aCell, aCell, 'C');
         if ~iscell(aCell)
            tooLazy = true;
         end
      catch  % do nothing
      end
      if tooLazy
         error(['*** ', mfilename, ': NULL accepted?!']);
      end
      
      try
         V = CStrCatStr(aCell, aCell, aCell);
         if ~iscell(aCell)
            tooLazy = true;
         end
      catch  % do nothing
      end
      if tooLazy
         error(['*** ', mfilename, ': NULL accepted?!']);
      end
   end
   
   disp('  Ok: Non-string input rejected.');
end

lasterr(errBak);

% Speed: -----------------------------------------------------------------------
% Find a suiting number of loops:
disp([char(10), '== Test Speed:']);
minT = eps;
C = strread(path, '%s', 'delimiter', pathsep);
if doSpeed
   iLoop     = 0;
   startTime = cputime;
   while cputime - startTime < 1.0
      v     = CStrCatStr('asd', C);
      iLoop = iLoop + 1;
   end
   nLoops = 1000 * ceil(iLoop / ((cputime - startTime) * 1000));
   disp([sprintf('  %d', nLoops) ' loops on this machine.']);
else
   disp('  Use at least 2 loops (displayed times are random!)');
   nLoops = 2;
end

% ------------------------------------------------------------------------------
if strcmpi(typeFun, mexext) && ExtrapolateSTRCAT
   % Reduce number of loops for Matlab version if compared with a MEX script:
   Mdiv     = 10;
   extraStr = '  (extrapolated)';
else
   Mdiv     = 1;
   extraStr = '';
end

tic;
mLoops = ceil(nLoops / Mdiv);
for i = 1:mLoops
   v2 = strcat('asd', C);
   clear('v2');
end
etMat = toc * Mdiv + minT;
v2    = strcat('asd', C);

tic;
for i = 1:nLoops
   v1 = CStrCatStr('asd', C);
   clear('v1');
end
etMex = toc + minT;
v1    = CStrCatStr('asd', C);

if isequal(v1, v2)
   disp(['  Cat ''asd'' and {1 x ', sprintf('%d', numel(C)), '}:']);
   disp(['    STRCAT:     ', sprintf('%6.2f', etMat), extraStr, ...
      char(10), '    CStrCatStr: ', sprintf('%6.2f', etMex), ...
      '   ==> ', sprintf('%.1f', 100 * etMex / etMat), '%']);
else
   error(['*** ', mfilename, ...
      ': Failed during speed test: cat(string, cell string).']);
end

% ------------------------------------------------------------------------------
fprintf('\n');
tic;
for i = 1:mLoops
   v1 = strcat(C, C);
   clear('v1');
end
etMat = toc * Mdiv + minT;
v1    = strcat(C, C);

tic;
for i = 1:nLoops
   v2 = CStrCatStr(C, C);
   clear('v2');
end
etMex = toc + minT;
v2    = CStrCatStr(C, C);

if isequal(v1, v2)
   tmpStr = ['{1 x ', sprintf('%d', numel(C)), '}'];
   disp(['  Cat ', tmpStr, ' with ', tmpStr, ':', char(10), ...
      '    STRCAT:     ', sprintf('%6.2f', etMat), extraStr, ...
      char(10), '    CStrCatStr: ', sprintf('%6.2f', etMex), ...
      '   ==> ', sprintf('%.1f', 100 * etMex / etMat), '%']);
else
   error(['*** ', mfilename, ...
      ': Failed during speed test: cat(cell string, cell string).']);
end

% ------------------------------------------------------------------------------
fprintf('\n');
tic;
for i = 1:mLoops
   v1 = strcat(C, 'asd', C);
   clear('v1');
end
etMat = toc * Mdiv + minT;
v1    = strcat(C, 'asd', C);

tic;
for i = 1:nLoops
   v2 = CStrCatStr(C, 'asd', C);
   clear('v2');
end
etMex = toc + minT;
v2    = CStrCatStr(C, 'asd', C);

if isequal(v1, v2)
   tmpStr = ['{1 x ', sprintf('%d', numel(C)), '}'];
   disp(['  Cat ', tmpStr, ' + ''asd'' + ', tmpStr, ':', ...
      char(10), '    STRCAT:     ', sprintf('%6.2f', etMat), extraStr, ...
      char(10), '    CStrCatstr: ', sprintf('%6.2f', etMex), ...
      '   ==> ', sprintf('%.1f', 100 * etMex / etMat), '%']);
else
   error(['*** ', mfilename, ...
      ': Failed during speed test: cat(cell string, string, cell string).']);
end

% ------------------------------------------------------------------------------
fprintf('\n');
tic;
for i = 1:mLoops
   v1 = strcat('bsd', C, 'asd');
   clear('v1');
end
etMat = toc * Mdiv + minT;
v1    = strcat('bsd', C, 'asd');

tic;
for i = 1:nLoops
   v2 = CStrCatStr('bsd', C, 'asd');
   clear('v2');
end
etMex = toc + minT;
v2    = CStrCatStr('bsd', C, 'asd');

if isequal(v1, v2)
   tmpStr = ['{1 x ', sprintf('%d', numel(C)), '}'];
   disp(['  Cat ''bsd'' + ', tmpStr, ' + ''asd'':', ...
      char(10), '    STRCAT:     ', sprintf('%6.2f', etMat), extraStr, ...
      char(10), '    CStrCatstr: ', sprintf('%6.2f', etMex), ...
      '   ==> ', sprintf('%.1f', 100 * etMex / etMat), '%']);
else
   error(['*** ', mfilename, ...
      ': Failed during speed test: cat(string, cell string, string).']);
end

% ------------------------------------------------------------------------------
% Create longer string and add a char to avoid shared data copies:
D = strcat(cat(2, C, C, C, C, C, C, C, C, C, C), '*');
nLoops = round(nLoops / 10);
mLoops = round(mLoops / 10);

fprintf('\n');
tic;
for i = 1:mLoops
   v1 = strcat('bsd', D, 'asd');
   clear('v1');
end
etMat = toc * Mdiv + minT;
v1    = strcat('bsd', D, 'asd');

tic;
for i = 1:nLoops
   v2 = CStrCatStr('bsd', D, 'asd');
   clear('v2');
end
etMex = toc + minT;
v2    = CStrCatStr('bsd', D, 'asd');

if isequal(v1, v2)
   tmpStr = ['{1 x ', sprintf('%d', numel(D)), '}'];
   disp(['  Cat ''bsd'' + ', tmpStr, ' + ''asd'':   ', ...
      sprintf('(%d loops)', nLoops), ...
      char(10), '    STRCAT:     ', sprintf('%6.2f', etMat), extraStr, ...
      char(10), '    CStrCatstr: ', sprintf('%6.2f', etMex), ...
      '   ==> ', sprintf('%.1f', 100 * etMex / etMat), '%']);
else
   error(['*** ', mfilename, ...
      ': Failed during speed test: cat(bsd, long cell string, string).']);
end

% ready. -----------------------------------------------------------------------
disp([char(10), 'CStrCatStr works well.']);

return;

% ******************************************************************************
function CheckMex(S1, S2, S3)

switch nargin
   case 2
      OrigReply = strcat(S1, S2);
      try
         R = CStrCatStr(S1, S2);
      catch
         error(['*** ', mfilename, ': Error for:', char(10), ...
            '  ', ShowStr(S1), char(10), '  ', ShowStr(S2), char(10), ...
            lasterr]);
      end
      
      if isequal(S1, {}) || isequal(S2, {})
         if ~isequal(R, {})
            error(['*** ', mfilename, ': Bad reply for: ', char(10), ...
               '  ', ShowStr(S1), char(10), '  ', ShowStr(S2), char(10), ...
               'Reply: ', ShowStr(R), char(10), ...
               'Reply must be {}!']);
         end
      elseif ~isequal(R, OrigReply)
         fprintf('\n');
         error(['*** ', mfilename, ': Bad reply for: ', char(10), ...
            '  ', ShowStr(S1), char(10), '  ', ShowStr(S2), ...
            'Reply: ', ShowStr(R)]);
      end
      
   case 3
      OrigReply = strcat(S1, S2, S3);
      try
         R = CStrCatStr(S1, S2, S3);
      catch
         error(['*** ', mfilename, ': Error for:', char(10), ...
            '  ', ShowStr(S1), char(10), '  ', ShowStr(S2), char(10), ...
            '  ', ShowStr(S3), char(10), lasterr]);
      end
      
      if isequal(S1, {}) || isequal(S2, {}) || isequal(S3, {})
         if ~isequal(R, {})
            error(['*** ', mfilename, ': Bad reply for: ', char(10), ...
               '  ', ShowStr(S1), char(10), '  ', ShowStr(S2), char(10), ...
               '  ', ShowStr(S3), char(10), 'Reply: ', ShowStr(R), ...
               char(10), 'Reply must be {}!']);
         end
      elseif ~isequal(R, OrigReply)
         fprintf('\n');
         error(['*** ', mfilename, ': Bad reply for: ', char(10), ...
            '  ', ShowStr(S1), char(10), '  ', ShowStr(S2), char(10), ...
            '  ', ShowStr(S3), char(10), 'Reply: ', ShowStr(R)]);
      end
      
   otherwise
      error(['*** ', mfilename, '(CheckMex)', ...
         ': Bad number of switches - programming error!']);
end

return;

% ******************************************************************************
function S = ShowStr(C)

if ischar(C)
   S = [char(39), C, char(39)];
elseif isempty(C)
   S = '{}';
elseif length(C) == 1
   S = sprintf('{''%s''}', C{1});
else
   S = ['{', sprintf('''%s'', ', C{1:length(C) - 1}), ...
      sprintf('''%s''}', C{length(C)})];
end

return;

% ******************************************************************************
function S = RandStr(Kind, N)
% Create a random string or cell string.
charA = 'A';
charB = 'B';

switch Kind
   case 'char'
      S = charA(ones(1, fix(rand * 5)));
      if isempty(S), S = ''; end        % No [1 x 0] strings as input
      
   case 'cell'
      if isempty(N)
         S = cell(1 + fix(rand * 10), 1 + fix(rand * 10));
      else
         S = cell(N(1), N(2));
      end
      for iS = 1:numel(S)
         S{iS} = charB(ones(1, fix(rand * 5)));
      end
      S(cellfun('isempty', S)) = {''};
      
   otherwise
      error(['*** ', mfilename, '(RandStr): Bad [Kind] - programming error!']);
end

return;
