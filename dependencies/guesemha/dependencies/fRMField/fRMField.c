// fRMField.c
// Fast RMFIELD: Remove field(s) from a struct
// This function is about 5 to 10 times faster than RMFIELD of Matlab 2009a.
//
// T = fRMField(S, Name)
// INPUT:
//   S:    Struct or struct array.
//   Name: String or cell string. Removing a name, which is not a field name
//         of S, is *not* an error here, in opposite to Matlab's RMFIELD.
// OUTPUT:
//   T:    Struct S without the removed fields.
//
// EXAMPLES:
//   S.A = 1; S.B = 2;
//   T = fRMField(S, {'B', 'C'});  %  >>  T.A = 1
//
// COMPILATION:
//   mex -O fRMField.c
// Consider C99 comments on Linux:
//   mex -O CFLAGS="\$CFLAGS -std=C99" fRMField.c
// Pre-compiled Mex: http://www.n-simon.de/mex
//
// TEST: Run TestfRMField to check validity and speed of the Mex function.
//
// Tested: Matlab 6.5, 7.7, 7.8, WinXP
//         Compiler: BCC5.5, LCC2.4/3.8, Open Watcom 1.8, MSVC++ 2008
// Author: Jan Simon, Heidelberg, (C) 2006-2010 matlab.THISYEAR(a)nMINUSsimon.de

/*
% $JRev: R0c V:002 Sum:aUJwNlc6v/Jm Date:19-Aug-2010 17:21:06 $
% $UnitTest: TestfRMField $
% $File: Tools\Mex\Source\fRMField.c $
% History:
% 001: 16-Aug-2010 21:43, I've tried it a lot to manage this with a shared
%      data copy and mxRemoveField afterwards. Even with mxUnshareArray and
%      mxUnreference I haven't found a clean implementation.
%      At least mxCreateSharedDataCopy can copy pointers to all original fields,
%      which 5 to 10 times faster than RMFIELD of Matlab 2009a. Although this
%      funciton is not documented, the speedup is dramatic if compared with
%      the deep copy by mxDuplicateArray.
%      mxGetFieldNameByNumber is not really fast: All field names are stored
%      in a single block with a fixed with of 64 bytes. Therefore matching the
%      field names and a large cell string could be done much faster - but this
%      is not documented and the speedup is important only for removing very
%      much fields.
*/

// =============================================================================
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
#define ERR_ID   "JSimon:fRMField:"
#define ERR_HEAD "fRMField[mex]: "

// There is an undocumented method to create a shared data copy. This is much
// faster, if the replied object is not changed, because it does not duplicate
// the contents of the array in the memory.
mxArray *mxCreateSharedDataCopy(const mxArray *mx);

#define COPY_ARRAY mxCreateSharedDataCopy
// #define COPY_ARRAY mxDuplicateArray     // slower, but documented

// Prototypes:
mwSize MatchField(const mxArray *S, mwSize *KeepIndex, const char **KeepField,
                  const mxArray *F);
     
// Main function ===============================================================
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  char Name[64];
  const char **KeepField;
  mwSize FieldNumber, iField, nField, nElem, iElem, *KeepIndex, nKeep;
  const mxArray *S;
  
  // Check number of arguments:
  if (nrhs != 2) {
     mexErrMsgIdAndTxt(ERR_ID   "BadNInput",
                       ERR_HEAD "2 inputs required.");
  }
  if (nlhs > 1) {
     mexErrMsgIdAndTxt(ERR_ID   "BadNOutput",
                       ERR_HEAD "1 output allowed.");
  }
  
  // Type of input arguments: Struct or empty matrix
  S = prhs[0];
  if (!mxIsStruct(S)) {
     // Allow empty matrix as input - nothing to remove:
     if (mxIsDouble(S) && mxGetNumberOfElements(S) == 0) {
        plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
        return;
     }
     mexErrMsgIdAndTxt(ERR_ID   "BadTypeInput1",
                       ERR_HEAD "1st input must be a struct.");
  }
  
  // Dimension of the struct:
  nField = mxGetNumberOfFields(S);
  nElem  = mxGetNumberOfElements(S);

  // Nothing to remove:
  if (nField == 0) {
     plhs[0] = COPY_ARRAY(S);
     return;
  }
     
  if (mxIsChar(prhs[1])) {  // String: -----------------------------------------
     // Obtain field Name:
     if (mxGetString(prhs[1], Name, 63)) {
        mexErrMsgIdAndTxt(ERR_ID   "NoMemory",
                          ERR_HEAD "Cannot convert Name to C-string.");
     }
  
     if ((FieldNumber = mxGetFieldNumber(S, Name)) != -1) {
        // The one and only field is removed:
        if (nField == 1) {
           plhs[0] = mxCreateStructArray(mxGetNumberOfDimensions(S),
                                         mxGetDimensions(S),
                                         0, NULL);
           return;
        }
        
        // Get list of field names:
        KeepField = (const char **) mxMalloc((nField - 1) * sizeof(char *));
        if (KeepField == NULL) {
           mexErrMsgIdAndTxt(ERR_ID   "NoMemory",
                             ERR_HEAD "Cannot get memory for KeepField.");
        }
        
        // Copy field names except for deleted one:
        for (iField = 0; iField < FieldNumber; iField++) {
           KeepField[iField] = mxGetFieldNameByNumber(S, iField);
        }
        for (iField = FieldNumber + 1; iField < nField; iField++) {
           KeepField[iField-1] = mxGetFieldNameByNumber(S, iField);
        }
        
        // Create the output struct:
        plhs[0] = mxCreateStructArray(mxGetNumberOfDimensions(S),
                                      mxGetDimensions(S),
                                      nField - 1, KeepField);

        // Copy fields for each element of the struct array S:
        for (iElem = 0; iElem < nElem; iElem++) {
           for (iField = 0; iField < FieldNumber; iField++) {
              mxSetFieldByNumber(plhs[0], iElem, iField,
                              COPY_ARRAY(mxGetFieldByNumber(S, iElem, iField)));
           }
           for (iField = FieldNumber + 1; iField < nField; iField++) {
              mxSetFieldByNumber(plhs[0], iElem, iField - 1,
                              COPY_ARRAY(mxGetFieldByNumber(S, iElem, iField)));
           }
        }

        mxFree(KeepField);
        
     } else {  // Name is not a field of S (no error here!):
        plhs[0] = COPY_ARRAY(S);
     }
     
  } else if (mxIsCell(prhs[1])) {  // Cell string: -----------------------------
     // Get memory for field names and the index vector:
     KeepField = (const char **) mxMalloc(nField * sizeof(char *));
     KeepIndex = (mwSize *) mxCalloc(nField, sizeof(mwSize));
     if (KeepField == NULL || KeepIndex == NULL) {
           mexErrMsgIdAndTxt(ERR_ID   "NoMemory",
                      ERR_HEAD "Cannot get memory for KeepField or KeepIndex.");
     }
     
     // Find fields to keep:
     nKeep = MatchField(S, KeepIndex, KeepField, prhs[1]);
     if (nKeep < nField) {  // Some fields have to be removed:
        // Create output struct:
        plhs[0] = mxCreateStructArray(mxGetNumberOfDimensions(S),
                                      mxGetDimensions(S),
                                      nKeep, KeepField);
        
        // Copy fields for each element of the struct array S:
        for (iElem = 0; iElem < nElem; iElem++) {
           for (iField = 0; iField < nKeep; iField++) {
              mxSetFieldByNumber(plhs[0], iElem, iField,
                   COPY_ARRAY(mxGetFieldByNumber(S, iElem, KeepIndex[iField])));
           }
        }

     } else {  // No fields to remove:
        plhs[0] = COPY_ARRAY(S);
     }
     
     mxFree(KeepField);
     mxFree(KeepIndex);
     
  } else {  // [NameList] is neither a string nor a cell string:
     mexErrMsgIdAndTxt(ERR_ID   "BadTypeInput1",
                       ERR_HEAD "[Name] must be string or cell string.");
  }
  
  return;
}

// =============================================================================
mwSize MatchField(const mxArray *S, mwSize *KeepIndex, const char **KeepField,
                  const mxArray *NameList)
{
  // Check existence of names in the input cell in the field names of the
  // input struct. This can be accelerated by getting a list of pointers to
  // all field names at first and search in this list instead of using
  // mxGetFieldNumber.
  
  mwSize iC, nC, FieldNumber, *IndexP, iField, nField;
  mxArray *aC;
  char Name[64];
    
  // Check exsitence of strings of [NameList]:
  nC = mxGetNumberOfElements(NameList);
  for (iC = 0; iC < nC; iC++) {
     if ((aC = mxGetCell(NameList, iC)) != NULL) {
        if (mxGetString(aC, Name, 63) == 0) {
           if ((FieldNumber = mxGetFieldNumber(S, Name)) != -1) {
              KeepIndex[FieldNumber] = 1;
           }
           
        } else {  // Name too long or not a string:
           mexErrMsgIdAndTxt(ERR_ID   "NoCellString",
                             ERR_HEAD "[NameList]: Cell element is no string.");
        }
        
     } else {     // NULL: Uninitialized cell element:
        mexErrMsgIdAndTxt(ERR_ID   "NoCellString",
                          ERR_HEAD "[NameList]: Uninitialized cell element.");
     }
          
  }
  
  // Reduce flag list to index list and get corresponding field names:
  IndexP = KeepIndex;
  nField = mxGetNumberOfFields(S);
  for (iField = 0; iField < nField; iField++) {
     if (KeepIndex[iField] == 0) {
        *IndexP++    = iField;
        *KeepField++ = mxGetFieldNameByNumber(S, iField);
     }
  }

  return (IndexP - KeepIndex);
}
