function S = fRMField(S, ToDelete)
% fRMField: Remove field(s) from a struct - fast [MEX]
% This function is about 5 to 10 times faster than RMFIELD of Matlab 2009a.
%
% T = fRMField(S, Name)
% INPUT:
%   S:    Struct or struct array.
%   Name: String or cell string. Removing a name, which is not a field name
%         of S, is *not* an error here, in opposite to Matlab's RMFIELD.
% OUTPUT:
%   T:    Struct S without the removed fields.
%
% EXAMPLES:
%   S.A = 1; S.B = 2;
%   T = fRMField(S, {'B', 'C'});  %  >>  T.A = 1
%   T = fRMField(S, 'A');         %  >>  T.B = 2
%
% COMPILATION: See fRMField.c
%
% TEST: Run TestfRMField to check validity and speed of the Mex function.
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP
% Author: Jan Simon, Heidelberg, (C) 2007-2010 matlab.THISYEAR(a)nMINUSsimon.de

% $JRev: R0g V:026 Sum:xDhgUft6JcQP Date:19-Aug-2010 23:57:17 $
% $License: BSD $
% $UnitTest: TestfRMField $
% $File: Tools\GLStruct\fRMField.m $
% 018: 28-Dec-2007 00:02, CELL2STRUCT without DIM is faster.

% ==============================================================================
% This is an implementation as M-file. It is still faster than RMFIELD of
% Matlab 2009a, but it needs the C-Mex function CStrAinBP (Jan Simon):
%   http://www.mathworks.com/matlabcentral/fileexchange/24380

% Prefer the C-Mex implementation of fRMField!
% Comment this out, if you want to use the M-version:
error(['JSimon:', mfilename, ':NoMex'], 'Cannot find compiled Mex file!');

% Accept the empty matrix to support Matlab 5.3:
if isempty(S) && isa(S, 'double')
   return;
end

allField = fieldnames(S);
allVal   = struct2cell(S);
if isempty(allField)  % Nothing to remove in struct([]):
   return;
end

% Find matching field names:
if ischar(ToDelete)
   KeepInd = ~strcmp(ToDelete, allField);
else
   % KeepInd = ~CStrisAinB(allField, ToDelete);  % Alternative, not published
   KeepInd = true(size(allField));
   KeepInd(CStrAinBP(allField, ToDelete)) = false;
end

% Create the new struct without the matching fields:
if any(KeepInd)
   if length(S) == 1
      S = cell2struct(allVal(KeepInd), allField(KeepInd));
   else  % Slower reshaping for structure array:
      sizV    = size(allVal);
      sizV(1) = sum(KeepInd);
      S = cell2struct( ...
         reshape(allVal(KeepInd, :), sizV), ...
         allField(KeepInd));
   end
else
   S = [];
end

return;
