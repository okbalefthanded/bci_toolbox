function R = CStrCatStr(A, B, C)
% Join strings and cell strings [Mex]
% Fast concatenation of 2 or 3 strings and cell strings.
%
% R = CStrCatStr(A, B, C)
% INPUT:
%   A, B, C: Strings or cell strings. At least one input must be a cell string
%      of any size. C is optional. The number of elements of cell strings must
%      be equal, if more than one input is a cell.
% OUTPUT:
%   R: Cell string with the same size as the input cell. If more than 1 input
%      is a cell, the size of the first cell is used. If any input is an empty
%      cell, the empty cell is replied. R contains the concatenated strings.
%
% - CStrCatStr accepts 2 or 3 inputs only and at least one must be a cell
%   string, but Matlab's STRCAT can process arbitrary inputs.
% - CStrCatStr conserves marginal spaces, STRCAT removes them for strings.
% - STRCAT('A', {}) replies: {'A'}.
%   CStrCatStr('A', {}) replies: {}, because the cell string rules.
% - The compiled MEX version is about 90% faster than STRCAT!
% - In the MEX verion, CHAR arrays are treated as string with linear index:
%   ['ac'; 'bd'] is processed as 'abcd'.
% - There is no need to accept 3 strings! CAT is faster in this case.
%
% EXAMPLES:
%   CStrCatStr('a', {'a', 'b', 'c'})       % ==>  {'aa', 'ab', 'ac'}
%   CStrCatStr({'a'; 'b'; 'c'}, '-')       % ==>  {'a-'; 'b-'; 'c-'}
%   CStrCatStr({' ', ''}, 'a', {' ', ''})  % ==>  {' a ', 'a'}
%   CStrCatStr('ba', {'di', 'du'}, 'm')    % ==>  {'badim', 'badum'}
%   CStrCatStr('a', 'b', 'c', 'd')         % ==>  error, just 3 inputs
%   CStrCatStr({'a', 'b'}, {'c'})          % ==>  error, cells need same size
%
%   Get file names with absolute path:
%     FileDir      = dir(PathName);
%     AbsoluteName = CStrCatStr(PathName, filesep, {FileDir.name});
%
% NOTE: STRCAT({'asd'}, {'bsd'}) is faster than STRCAT('asd', {'bsd'}).
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP, [UnitTest]
% Author: Jan Simon, Heidelberg, (C) 2009-2010 matlab.THISYEAR(a)nMINUSsimon.de

% $JRev: R0n V:014 Sum:t7MAYI1KHRww Date:11-Feb-2010 01:28:24 $
% $License: BSD (see Docs\BSD_License.txt) $
% $File: Published\CStrCatStr\CStrCatStr.m $

% Do the work: =================================================================
% This M-version is a proof of concept and its output is used for testing the
% MEX-version. However, it is 20%-30% faster than Matlab's STRCAT, if one input
% is a string.
% The types of cell elements are not checked here, but in MEX function.
warning('JSim:CStrCatStr:NoMex', 'Using Matlab version instead of fast MEX.');

switch nargin
case 2
   if ischar(A)
      R = cell(size(B));
      for iB = 1:numel(B)
         R{iB} = [A, B{iB}];  % Linear index for R
      end
   elseif ischar(B)
      R = cell(size(A));
      for iA = 1:numel(A)
         R{iA} = [A{iA}, B];
      end
   elseif isa(A, 'cell') && isa(B, 'cell')
      if isempty(A) || isempty(B)
         R = {};
      else
         R = cell(size(A));
         for iA = 1:numel(A)
            R{iA} = [A{iA}, B{iA}];
         end
      end
   else
      error('JSim:CStrCatStr:BadInput', ...
         'At least one cell string needed as input.');
   end
   
case 3  % 3 inputs: ------------------------------------------------------------
   % Check types of inputs:
   flagCell = [isa(A, 'cell'), isa(B, 'cell'), isa(C, 'cell')];
   flagChar = [ischar(A), ischar(B), ischar(C)];
   if all(or(flagCell, flagChar)) == 0
      error('JSim:CStrCatStr:BadInput', ...
         'Inputs must be strings or cell strings.');
   end
   
   tmp = [1, 2, 4];
   switch sum(tmp(flagCell))
      case 0  % String + String + String
         error('JSim:CStrCatStr:BadInput', ...
               'At least one cell string needed as input.');
      case 1  % Cell + String + String
         S = [B, C];
         R = cell(size(A));
         for iR = 1:numel(R)
            R{iR} = [A{iR}, S];
         end
      
      case 2  % String + Cell + String
         R = cell(size(B));
         for iR = 1:numel(R)
            R{iR} = [A, B{iR}, C];
         end
         
      case 3  % Cell + Cell + String
         if numel(A) ~= numel(B)
            error('JSim:CStrCatStr:BadInput', 'Input cells need same size.');
         end
         
         R = cell(size(A));
         for iR = 1:numel(R)
            R{iR} = [A{iR}, B{iR}, C];
         end
         
      case 4  % String + String + Cell
         S = [A, B];
         R = cell(size(C));
         for iR = 1:numel(R)
            R{iR} = [S, C{iR}];
         end
         
      case 5  % Cell + String + Cell
         if numel(A) ~= numel(C)
            error('JSim:CStrCatStr:BadInput', 'Input cells need same size.');
         end
         
         R = cell(size(A));
         for iR = 1:numel(R)
            R{iR} = [A{iR}, B, C{iR}];
         end
         
      case 6  % String + Cell + Cell
         if numel(B) ~= numel(C)
            error('JSim:CStrCatStr:BadInput', 'Input cells need same size.');
         end
         
         R = cell(size(B));
         for iR = 1:numel(R)
            R{iR} = [A, B{iR}, C{iR}];
         end
         
      case 7  % Cell + Cell + Cell
         if numel(A) ~= numel(B) || numel(B) ~= numel(C)
            error('JSim:CStrCatStr:BadInput', 'Input cells need same size.');
         end
         
         R = cell(size(A));
         for iR = 1:numel(R)
            R{iR} = [A{iR}, B{iR}, C{iR}];
         end
         
      otherwise  % Actually impossible, but never SWITCH without OTHERWISE:
         error('JSim:CStrCatStr:BadInput', 'Programming error.');
   end
   
otherwise
   error('JSim:CStrCatStr:BadNArgin', '2 or 3 inputs are required.');
end

return;
