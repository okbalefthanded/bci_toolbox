function String = CStr2String(CStr, Sep, Trail)
% Concatenate strings of a cell string [MEX]
% This equals CAT(2, C{:}) and SPRINTF('%s', C{:}), but is remarkably faster,
% because the output is pre-allocated.
%
% Str = CStr2String(CStr, Separator, Trail)
% INPUT:
%   CStr: Cell string of any size. All not-empty cell elements must be
%         strings ([1 x N] CHAR vectors).
%   Separator: String, which is appended after each string of CStr.
%         This is thought to simulate: "sprintf(['%s', Sep], CStr{:})".
%         Optional, default: ''.
%   Trail: String or logical flag. For 'noTrail' or FALSE the trailing
%         separator is omitted. Optional, default: 'Trail'.
%
% OUTPUT:
%   Str:  [1 x M] CHAR vector, concatenated strings of the input.
%
% EXAMPLES:
% Write a cell string to a file:
%   Slow: fprintf(FID, '%s\n', CStr{:});
%   Fast: fwrite(FID, CStr2String(CStr, char(10)), 'uchar');
% A comma-separated list;
%   CStr = {'First', 'Second', 'Third'});
%   Str = CStr2String(CStr, ', ', 'noTrail');
%   % >> 'First, Second, Third'
%
% COMPILATION:
%   mex -O CStr2String.c
%   or download from: http://www.n-simon.de/mex
%   Please run the unit-test uTest_CStr2String after compiling!
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP
%         Compatibility to other Matlab versions, Mac and Linux is assumed.
% Author: Jan Simon, Heidelberg, (C) 2009 matlab.THISYEAR(a)nMINUSsimon.de
%
% See also: CAT, SPRINTF, STRCAT, Cell2Vec.

% $JRev: R0k V:010 Sum:DApC69jtwyTA Date:22-Sep-2010 02:30:25 $
% $License: BSD (see Docs\BSD_License.txt) $
% $UnitTest: uTest_CStr2String $
% $File: Tools\GLString\CStr2String.m $
% History:
% 001: 11-Dec-2009 09:28, Faster replacement of CAT for cell string cat.
%      Published.
% 004: 19-Apr-2010 17:15, Allow disabling of the trailing separator.
% 006: 21-Jul-2010 09:59, M-version works with "\" in the separator.

% Initialize: ==================================================================
% Prefer the fast Mex!!!
% error(['JSimon:', mfilename, ':NoMEX'], 'Cannot find compiled MEX file.');

% Do the work: =================================================================
% This is just a proof of concept to test effect of pre-allocation in Matlab:
nArg = nargin;
if nArg == 1
   Len = cellfun('prodofsize', CStr);
   String(1, 1:sum(Len)) = char(0);
   index1 = 1;
   for iC = 1:numel(CStr)
      index2 = index1 + Len(iC) - 1;
      String(index1:index2) = CStr{iC};
      index1 = index2 + 1;
   end
   
   % CAT would be faster here - so better use the MEX!
   % String = cat(2, CStr{:});
elseif nArg == 2
   Sep    = strrep(Sep, '\', '\\');
   String = sprintf(['%s', Sep], CStr{:});
   
elseif nArg == 3
   Sep    = strrep(Sep, '\', '\\');
   String = sprintf(['%s', Sep], CStr{:});
   if ischar(Trail)
      if strncmpi(Trail, 'n', 1)
         String = String(1:length(String) - length(Sep));
      end
   elseif any(Trail)
      String = String(1:length(String) - length(Sep));
   end
   
else
   error(['JSimon:', mfilename, ':BadNInput'], '1 to 3 inputs allowed.');
end

% Avoid [1-by-0] char array:
if isempty(String)
   String = '';
end

return;
