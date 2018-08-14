// CStr2String.c
// Concatenate strings of a cell string
// This equals CAT(2, C{:}) and SPRINTF('%s', C{:}), but is remarkably faster,
// because the output is pre-allocated.
//
// Str = CStr2String(CStr, Separator, Trail)
// INPUT:
//   CStr: Cell string of any size. All not-empty cell elements must be
//         strings ([1 x N] CHAR vectors).
//   Separator: String, which is appended after each string of CStr.
//         This is thought to simulate: "sprintf(['%s', Sep], CStr{:})".
//         Optional, default: ''.
//   Trail: String or logical flag. For 'noTrail' or FALSE the trailing
//         separator is omitted. Optional, default: TRUE.
//
// OUTPUT:
//   Str:  [1 x N] CHAR vector.
//
// EXAMPLE:
// Write cell strings to a file:
//   Slow: fprintf(FID, '%s\n', CStr{:});
//   Fast: fwrite(FID, CStr2String(CStr, char(10)), 'uchar');
// A comma-separated list:
//   CStr = {'First', 'Second', 'Third'});
//   Str = CStr2String(CStr, ', ', 'noTrail');
//   % >> 'First, Second, Third'
//
// COMPILATION:
//   (mex -setup   % if not done before)
//   mex -O CStr2String.c
// Linux: consider C99 comments:
//   mex -O CFLAGS="\$CFLAGS -std=C99" Cell2Vec.c
// Download: http://www.n-simon.de/mex
// Run the unit-test uTest_CStr2String after compiling.
//
// Tested: Matlab 6.5, 7.7, 7.8, WinXP, 32bit
//         Compiler: LCC2.4/3.8, BCC5.5, OWC1.8, MSVC2008
// Assumed Compatibility: higher Matlab versions, Mac, Linux, 64bit
// Author: Jan Simon, Heidelberg, (C) 2009-2010 matlab.THISYEAR(a)nMINUSsimon.de

/*
% $JRev: R0n V:013 Sum:hYBiThcHY0A2 Date:01-Oct-2008 14:29:37 $
% $License: BSD (see Docs\BSD_License.txt) $
% $UnitTest: uTest_CStr2String $
% $File: Tools\Mex\Source\CStr2String.c $
% History:
% 001: 11-Dec-2009 09:28, Faster replacement of CAT for cell string cat.
%      Published.
% 007: 19-Apr-2010 17:42, 3rd input to omit trailing separator.
*/

#include "mex.h"
#include <string.h>

// Assume 32 bit addressing for Matlab 6.5:
// See MEX option "compatibleArrayDims" for MEX in Matlab >= 7.7.
#ifndef MWSIZE_MAX
#define mwSize  int32_T           // Defined in tmwtypes.h
#define mwIndex int32_T
#define MWSIZE_MAX MAX_int32_T
#endif

// Error messages do not contain the function name in Matlab 6.5! This is not
// necessary in Matlab 7, but it does not bother:
#define ERR_HEAD "CStr2String: "
#define ERR_ID   "JSimon:CStr2String:"

// Prototypes:
void Join       (mxChar *P, const mxArray *C, const mwSize nC);
void JoinNULL   (mxChar *P, const mxArray *C, const mwSize nC);
void JoinSep    (mxChar *P, const mxArray *C, mwSize nC,
                 const mxChar *Sep, const mwSize SepLen, bool Trail);
void JoinSepNULL(mxChar *P, const mxArray *C, mwSize nC,
                 const mxChar *Sep, const mwSize SepLen, bool Trail);

// Main function ===============================================================
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   const mxArray *C, *aC, *TrailArg;
   mwSize SumLen = 0, Len, nC, Dims[2], SepLen;
   mwIndex iC;
   mxChar *Sep, *TrailInput;
   bool anyNULL = false, addSep, Trail = true;
   
   // Check inputs:
   if (nrhs == 0 || nrhs > 3) {
      mexErrMsgIdAndTxt(ERR_ID   "BadNInput",
                        ERR_HEAD "1 to 3 inputs required.");
   }
   
   addSep = (nrhs >= 2);
   if (addSep) {
      if (!mxIsChar(prhs[1])) {
         mexErrMsgIdAndTxt(ERR_ID   "BadInput2",
                           ERR_HEAD "2nd input [Sep] must be a string.");
      }
      
      Sep    = mxGetData(prhs[1]);
      SepLen = mxGetNumberOfElements(prhs[1]);
      if (SepLen == 0) {
         addSep = false;
      }
      
      // Get 3rd input, string or logical/numerical flag:
      if (nrhs == 3) {
         TrailArg = prhs[2];
         if (mxIsNumeric(TrailArg) || mxIsLogical(TrailArg)) {
            if (!mxIsEmpty(TrailArg)) {
               Trail = (mxGetScalar(TrailArg) != 0.0);
            }
            
         } else if (mxIsChar(TrailArg)) {
            if (!mxIsEmpty(TrailArg)) {
               TrailInput = (mxChar *) mxGetData(TrailArg);
               Trail      = (*TrailInput != L'n' && *TrailInput != L'N');
            }
         
         } else {
            mexErrMsgIdAndTxt(ERR_ID   "BadInput2",
                              ERR_HEAD "3rd input [Trail] must be a string.");
         }
      }
   }
   
   // Check number of outputs:
   if (nlhs > 1) {
      mexErrMsgIdAndTxt(ERR_ID   "BadNOutput",
                        ERR_HEAD "1 output allowed.");
   }
   
   // Create a pointer to the input cell and check the type:
   C = prhs[0];
   if (!mxIsCell(C)) {
      mexErrMsgIdAndTxt(ERR_ID   "BadInput1_Type",
                        ERR_HEAD "1st Input must be a cell string.");
   }
   
   // Get number of dimensions of the input string and cell:
   nC = mxGetNumberOfElements(C);
   
   // Nothing to do for empty input:
   if (nC == 0) {
      plhs[0] = mxCreateString("");
      return;
   }
   
   // Get sum of lenghts and check if all cell non-empty elements are strings:
   for (iC = 0; iC < nC; iC++) {
      aC = mxGetCell(C, iC);
      if (aC != NULL) {
         Len     = mxGetNumberOfElements(aC);
         SumLen += Len;
         if (Len != 0) {
            if (!mxIsChar(aC)) {
               mexErrMsgIdAndTxt(ERR_ID   "CellIsNoString",
                                 ERR_HEAD "Cell element is not a string.");
            }
            if (mxGetM(aC) != 1) {
               mexErrMsgIdAndTxt(ERR_ID   "CellIsCharArray",
                                 ERR_HEAD "Cannot handle CHAR arrays.");
            }
         }
      } else {
         // NULL means a not initialized cell element. It is treated as empty
         // matrix as usual in Matlab:
         anyNULL = true;
      }
   }
   
   // Add length of separators:
   if (addSep) {
      SumLen += SepLen * (Trail ? nC : nC - 1);
   }
   
   // Create output string:
   Dims[0] = 1;
   Dims[1] = SumLen;
   if((plhs[0] = mxCreateCharArray(2, Dims)) == NULL) {
      mexErrMsgIdAndTxt(ERR_ID   "NoMemory",
                        ERR_HEAD "Cannot create output.");
   }
   
   // Copy strings to the output string:
   if (anyNULL) {       // Accept NULL elements (some % slower):
      if (addSep) {     // No separators:
         JoinSepNULL(mxGetData(plhs[0]), C, nC, Sep, SepLen, Trail);
      } else {          // Append separator after each string:
         JoinNULL(mxGetData(plhs[0]), C, nC);
      }
      
   } else {             // No NULL elements:
      if (addSep) {     // No separators:
         JoinSep(mxGetData(plhs[0]), C, nC, Sep, SepLen, Trail);
      } else {          // Append separator after each string:
         Join(mxGetData(plhs[0]), C, nC);
      }
   }
   
   return;
}

// =============================================================================
void Join(mxChar *P, const mxArray *C, const mwSize nC)
{
   mwIndex iC;
   mwSize Len;
   const mxArray *aC;
   
   for (iC = 0; iC < nC; iC++) {
      aC  = mxGetCell(C, iC);
      Len = mxGetNumberOfElements(aC);
      memcpy(P, mxGetData(aC), Len * sizeof(mxChar));
      P  += Len;
   }
   
   return;
}

// =============================================================================
void JoinNULL(mxChar *P, const mxArray *C, const mwSize nC)
{
   // Some of the cells are NULL pointers, which must be excluded.
   mwIndex iC;
   mwSize Len;
   const mxArray *aC;
   
   for (iC = 0; iC < nC; iC++) {
      aC = mxGetCell(C, iC);
      if (aC != NULL) {
         Len = mxGetNumberOfElements(aC);
         memcpy(P, mxGetData(aC), Len * sizeof(mxChar));
         P += Len;
      }
   }
   
   return;
}

// =============================================================================
void JoinSep(mxChar *P, const mxArray *C, mwSize nC,
             const mxChar *Sep, const mwSize SepLen, bool Trail)
{
   mwIndex iC;
   mwSize Len;
   const mxArray *aC;
   mwSize SepByte = SepLen * sizeof(mxChar);
   
   // Concatenate elements 1 to NUMEL(C)-1:
   nC--;
   for (iC = 0; iC < nC; iC++) {
      aC  = mxGetCell(C, iC);
      Len = mxGetNumberOfElements(aC);
      memcpy(P, mxGetData(aC), Len * sizeof(mxChar));
      P  += Len;
      memcpy(P, Sep, SepByte);
      P  += SepLen;
   }
   
   // Append last element and a trailing separator on demand:
   aC  = mxGetCell(C, nC);
   Len = mxGetNumberOfElements(aC);
   memcpy(P, mxGetData(aC), Len * sizeof(mxChar));
   if (Trail) {
      memcpy(P + Len, Sep, SepByte);
   }
   
   return;
}

// =============================================================================
void JoinSepNULL(mxChar *P, const mxArray *C, mwSize nC,
                 const mxChar *Sep, const mwSize SepLen, bool Trail)
{
   // Some of the cells are NULL pointers, which must be excluded.
   mwIndex iC;
   mwSize Len;
   const mxArray *aC;
   mwSize SepByte = SepLen * sizeof(mxChar);
 
   nC--;
   for (iC = 0; iC < nC; iC++) {
      aC = mxGetCell(C, iC);
      if (aC != NULL) {
         Len = mxGetNumberOfElements(aC);
         memcpy(P, mxGetData(aC), Len * sizeof(mxChar));
         P += Len;
         memcpy(P, Sep, SepByte);
         P += SepLen;
      } else {
         memcpy(P, Sep, SepByte);
         P += SepLen;
      }
   }
   
   aC = mxGetCell(C, nC);
   if (aC != NULL) {
      Len = mxGetNumberOfElements(aC);
      memcpy(P, mxGetData(aC), Len * sizeof(mxChar));
      P  += Len;
   }
   if (Trail) {
      memcpy(P, Sep, SepByte);
   }

   return;
}
